module Chaintown
  module Callbacks
    extend ActiveSupport::Concern

    included do
      class_attribute :before_step_actions, default: []
      class_attribute :after_step_actions, default: []
      class_attribute :around_step_actions, default: []

      delegate :before_step_actions, :after_step_actions, :around_step_actions, to: :class
    end

    class_methods do
      def before_step_action(*callbacks)
        before_step_actions.concat(callbacks)
      end

      def after_step_action(*callbacks)
        after_step_actions.concat(callbacks)
      end

      def around_step_action(*callbacks)
        around_step_actions.concat(callbacks)
      end
    end

    def run_before_actions
      before_step_actions.each { |callback| send(callback) }
    end

    def run_after_actions
      after_step_actions.each { |callback| send(callback) }
    end

    def with_around_actions
      if around_step_actions.present?
        callbacks = around_step_actions.dup
        around_callback(callbacks.delete_at(0), callbacks) { yield }
      else
        yield
      end
    end

    def around_callback(callback, nested_callbacks, &block)
      send(callback) do
        if nested_callbacks.present?
          around_callback(nested_callbacks.delete_at(0), nested_callbacks, &block)
        else
          block.call
        end
      end
    end
  end
end
