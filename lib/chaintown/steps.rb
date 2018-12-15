# This module add DLS for defininig steps or failed_steps.
# All steps are of type Chaintown::Step.
module Chaintown
  module Steps

    # When module is included we want to make steps and failed_steps
    # instance variables
    def self.included(base)
      base.class_eval do
        attr_writer :steps, :failed_steps

        define_method(:steps) do
          instance_variable_get(:@steps) || instance_variable_set(:@steps, [])
        end

        define_method(:failed_steps) do
          instance_variable_get(:@failed_steps) || instance_variable_set(:@failed_steps, [])
        end
      end
    end

    # When module is extended we want to make steps and failed steps
    # variabled of specific class type, so every class will have its own
    # list of steps
    def self.extended(base)
      base.class_eval do
        attr_writer :steps, :failed_steps

        define_singleton_method(:steps) do
          instance_variable_get(:@steps) || instance_variable_set(:@steps, [])
        end

        define_singleton_method(:failed_steps) do
          instance_variable_get(:@failed_steps) || instance_variable_set(:@failed_steps, [])
        end
      end
    end

    # DLS method to add new step to the list
    def step(step_handler, **params, &block)
      steps << init_step(step_handler, params, &block)
    end

    # DSL method to add new step called when process will fail
    def failed_step(step_handler, **params, &block)
      failed_steps << init_step(step_handler, params, &block)
    end

    # Callback, assure that we add steps from parent class
    def inherited(subclass)
      [:steps, :failed_steps].each do |inheritable_attribute|
        instance_var = "@#{inheritable_attribute}"
        subclass.instance_variable_set(instance_var, instance_variable_get(instance_var).dup || [])
      end
    end

  private

    def init_step(step_handler, params = {}, &block)
      Chaintown::Step.new(step_handler).tap do |new_step|
        new_step.if_condition = params[:if] if params.present?
        new_step.instance_eval(&block) if block_given?
      end
    end
  end
end
