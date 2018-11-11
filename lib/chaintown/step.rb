module Chaintown
  class Step
    include Chaintown::Steps

    attr_reader :step_handler
    attr_accessor :if_condition

    def initialize(step_handler)
      @step_handler = step_handler
    end
  end
end
