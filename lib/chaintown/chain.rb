# This module add ability to define chain of steps
# which will be called in order.
# Every step is a method in the class which include this module.
# Every class receive state and immutable params.
#
# State is used to keep information which will be shared between
# steps. State should inherit from Chaintown::State.
# Steps are calls only when state is valid in other case invocation
# is stopped and moved to run steps defined as failed.
#
# We can add conditions to step by using *if* parameter.
# We can also nest steps.
#
# Example:
#
#   step :step1
#   step :step2, if: proc { |state, params| params[:run_step_2] }
#   step :step3 do
#     step :step4
#   end
#   failed_step :step5
#
module Chaintown
  module Chain
    extend ActiveSupport::Concern

    included do
      self.extend Chaintown::Steps
      self.include Chaintown::Callbacks

      attr_reader :state, :params
      attr_accessor :current_step
      delegate :steps, :failed_steps, to: :class
    end

    def initialize(state, params)
      @state, @params = state, params.freeze
    end

    def perform
      perform_steps(steps, failed_steps)
      state
    end

  protected

    def current_step_name
      current_step&.step_handler.to_s
    end

  private

    def perform_steps(steps, failed_steps)
      steps.each do |step|
        break unless state.valid?
        next unless step.if_condition.blank? || self.instance_exec(&step.if_condition)
        perform_step(step)
      end
      unless state.valid?
        failed_steps.each do |step|
          next unless step.if_condition.blank? || self.instance_exec(&step.if_condition)
          perform_step(step)
        end
      end
    end

    def perform_step(step)
      self.current_step = step # set step to use in callbacks
      run_before_actions
      with_around_actions do
        if step.steps.present?
          method(step.step_handler).call do
            perform_steps(step.steps, step.failed_steps)
            self.current_step = step # set proper step to use in callbacks after processing nested steps
          end
        else
          method(step.step_handler).call
        end
      end
      run_after_actions
    end
  end
end
