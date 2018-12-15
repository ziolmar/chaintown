module Chaintown
  class State
    attr_accessor :result, :valid
    alias_method :valid?, :valid

    def initialize
      @valid = true
    end

    def failed(result)
      @valid = false
      @result = result
    end
  end
end
