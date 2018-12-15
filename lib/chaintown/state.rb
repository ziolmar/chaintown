module Chaintown
  class State
    attr_accessor :result, :valid
    alias_method :valid?, :valid

    def initialize
      @valid = true
      @enroll_count = 0
    end

    def failed(result)
      @valid = false
      @result = result
    end
  end
end
