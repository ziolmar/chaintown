require 'spec_helper'

RSpec.describe Chaintown do

  it 'has a version number' do
    expect(Chaintown::VERSION).not_to be nil
  end

  describe Chaintown::Chain do
    class ChainService
      include Chaintown::Chain

      step :step1
      step :step2, if: proc { |_state, params| params[:run_step_2] }
      step :step3, if: proc { |_state, params| params[:run_step_3] }
      step :step4 do
        step :step5
      end

      [:step1, :step2, :step3, :step5].each do |method_name|
        define_method(method_name) do
        end
      end

      def step4
        yield
      end
    end

    it 'should run chain of methods properly' do
      service = ChainService.new(Chaintown::State.new, run_step_2: false, run_step_3: true)

      expect(service).to receive(:step1).and_call_original
      expect(service).to_not receive(:step2)
      expect(service).to receive(:step3).and_call_original
      expect(service).to receive(:step4).and_call_original
      expect(service).to receive(:step5).and_call_original

      service.perform
    end
  end
end
