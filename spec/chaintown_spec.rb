require 'spec_helper'

RSpec.describe Chaintown do

  it 'has a version number' do
    expect(Chaintown::VERSION).not_to be nil
  end

  describe Chaintown::Chain do
    class Step6Handler
      attr_reader :state, :params

      def initialize(state, params)
        @state, @params = state, params
      end

      def call
      end
    end

    class ChainService
      include Chaintown::Chain

      before_step_action :before_every_step_action
      after_step_action :after_every_step_action
      around_step_action :around_every_step_action

      step :step1
      step :step2, if: proc { |_state, params| params[:run_step_2] }
      step :step3, if: proc { |_state, params| params[:run_step_3] }
      step :step4 do
        step :step5
        step Step6Handler
      end

      [:step1, :step2, :step3, :step5].each do |method_name|
        define_method(method_name) do
        end
      end

      def step4
        yield
      end

      def before_every_step_action
        puts "before action"
      end

      def after_every_step_action
        puts 'after action'
      end

      def around_every_step_action
        puts 'before around'
        yield
        puts 'after around'
      end
    end

    it 'should run chain of methods properly' do
      service = ChainService.new(Chaintown::State.new, run_step_2: false, run_step_3: true)

      expect(service).to receive(:step1).and_call_original
      expect(service).to_not receive(:step2)
      expect(service).to receive(:step3).and_call_original
      expect(service).to receive(:step4).and_call_original
      expect(service).to receive(:step5).and_call_original
      expect_any_instance_of(Step6Handler).to receive(:call).and_call_original

      service.perform
    end
  end
end
