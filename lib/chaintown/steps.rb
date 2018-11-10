# This module add DLS for defininig steps or failed_steps.
# All steps are of type Chaintown::Step.
module Chaintown
  module Steps
    def self.included(base)
      base.class_eval do
        attr_writer :steps, :failed_steps

        define_method(:steps) do
          instance_variable_get(:@steps) || []
        end

        define_method(:failed_steps) do
          instance_variable_get(:@failed_steps) || []
        end
      end
    end

    def self.extended(base)
      base.class_eval do
        class_attribute :steps, default: []
        class_attribute :failed_steps, default: []
      end
    end

    def step(method_name, **params, &block)
      steps << init_step(method_name, params, &block)
    end

    def failed_step(method_name, **params, &block)
      failed_steps << init_step(method_name, params, &block)
    end

  private

    def init_step(method_name, params = {}, &block)
      Chaintown::Step.new(method_name).tap do |new_step|
        new_step.if_condition = params[:if] if params.present?
        new_step.instance_eval(&block) if block_given?
      end
    end
  end
end
