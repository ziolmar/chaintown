module Chaintown
  class Step
    include Chaintown::Steps

    attr_reader :method_name
    attr_accessor :if_condition

    def initialize(method_name)
      @method_name = method_name
    end

    def steps
      @steps ||= []
    end
  end
end
