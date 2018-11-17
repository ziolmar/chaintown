require 'spec_helper'

RSpec.describe Chaintown do

  it 'has a version number' do
    expect(Chaintown::VERSION).not_to be nil
  end

  describe Chaintown::Chain do
    class ChainService
      include Chaintown::Chain

      before_step_action :before_action_1, :before_action_2
      after_step_action :after_action
      around_step_action :around_action

      step :step1
      step :step2, if: proc { params[:run_step_2] }
      step :step3, if: proc { params[:run_step_3] }
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

      def before_action_1
      end

      def before_action_2
      end

      def after_action
      end

      def around_action
        yield
      end
    end

    it 'should run chain of methods properly' do
      service = ChainService.new(Chaintown::State.new, run_step_2: false, run_step_3: true)

      # steps
      expect(service).to receive(:step1).and_call_original
      expect(service).to_not receive(:step2)
      expect(service).to receive(:step3).and_call_original
      expect(service).to receive(:step4).and_call_original
      expect(service).to receive(:step5).and_call_original

      # callbacks
      expect(service).to receive(:before_action_1).exactly(4).times.and_call_original
      expect(service).to receive(:before_action_2).exactly(4).times.and_call_original
      expect(service).to receive(:after_action).exactly(4).times.and_call_original
      expect(service).to receive(:around_action).exactly(4).times.and_call_original

      service.perform
    end
  end
end
