RSpec.describe Operatic do
  describe '.call' do
    let(:klass) {
      Class.new do
        include Operatic
      end
    }

    context 'when neither #failure! or #success! are explicitly called' do
      it 'returns a frozen success result' do
        result = klass.call

        expect(result).to be_success
        expect(result).to be_frozen
        expect(result.to_h).to eql({})
        expect(result.to_h).to be_frozen
      end
    end

    context 'when called with something other than kwargs' do
      it 'raises ArgumentError', :aggregate_failures do
        expect { klass.call('Dave') }.to raise_error(ArgumentError)
        expect { klass.call(['Dave']) }.to raise_error(ArgumentError)

        if RUBY_VERSION >= '3.1'
          expect { klass.call({ name: 'Dave' }) }.to raise_error(ArgumentError)
        end
      end
    end
  end

  describe '.call!' do
    let(:klass) {
      Class.new do
        include Operatic

        attr_reader :oh_no

        def call
          failure! if oh_no
        end
      end
    }

    context 'when the result is a success' do
      it do
        expect(klass.call!).to be_success
      end
    end

    context 'when the result is a failure' do
      it do
        expect {
          klass.call!(oh_no: true)
        }.to raise_error(Operatic::FailureError)
      end
    end
  end

  describe '.result_attr' do
    let(:klass) {
      Class.new do
        include Operatic

        result_attr :a, :b

        def call
          result.a = 1

          success!(
            b: 2,
            c: 3,
          )
        end
      end
    }

    it 'adds attribute accessors to its result' do
      result = klass.call

      expect(result).to be_success
      expect(result).to be_frozen
      expect(result.a).to eql(1)
      expect(result.b).to eql(2)
      expect(result).not_to respond_to(:c)
      expect(result.to_h).to eql({ a: 1, b: 2, c: 3 })
      expect(result.to_h).to be_frozen
    end

    it 'only defines accessors on its own result class' do
      another_klass = Class.new do
        include Operatic
      end

      klass.call
      another_result = another_klass.call

      expect(another_result).not_to respond_to(:a)
    end
  end

  describe 'overriding #initialize' do
    let(:klass) {
      Class.new do
        include Operatic

        def initialize(name:)
          @name = name
        end

        def call
          result.success!(message: "Hello #{@name}")
        end
      end
    }

    it 'works as expected with known arguments' do
      result = klass.call(name: 'Bob')

      expect(result[:message]).to eql('Hello Bob')
    end

    it 'works as expected with unknown arguments' do
      expect {
        klass.call(foo: 'bar')
      }.to raise_error(ArgumentError)
    end
  end

  describe '#failure!' do
    let(:klass) {
      Class.new do
        include Operatic

        attr_reader :call_twice
        attr_reader :early_failure
        attr_reader :early_failure_with_data
        attr_reader :failure_after_setting_data
        attr_reader :failure_after_success

        def call
          if call_twice
            failure!
            return failure!
          end

          return failure! if early_failure

          return failure!(a: 1, b: 2) if early_failure_with_data

          if failure_after_setting_data
            result[:c] = 3
            return failure!
          end

          if failure_after_success
            success!
            return failure!
          end
        end
      end
    }

    context 'when called with no data' do
      it do
        result = klass.call(early_failure: true)

        expect(result).to be_failure
        expect(result).to be_frozen
        expect(result.to_h).to eql({})
        expect(result.to_h).to be_frozen
      end
    end

    context 'when called with data' do
      it do
        result = klass.call(early_failure_with_data: true)

        expect(result).to be_failure
        expect(result).to be_frozen
        expect(result.to_h).to eql({ a: 1, b: 2 })
        expect(result.to_h).to be_frozen
      end
    end

    context 'when called after setting data on the result object' do
      it do
        result = klass.call(failure_after_setting_data: true)

        expect(result).to be_failure
        expect(result).to be_frozen
        expect(result.to_h).to eql({ c: 3 })
        expect(result.to_h).to be_frozen
      end
    end

    context 'when called more than once' do
      it do
        expect {
          klass.call(call_twice: true)
        }.to raise_error(FrozenError)
      end
    end

    context 'when called after #success!' do
      it do
        expect {
          klass.call(failure_after_success: true)
        }.to raise_error(FrozenError)
      end
    end
  end

  describe '#success!' do
    let(:klass) {
      Class.new do
        include Operatic

        attr_reader :call_after_failure
        attr_reader :call_after_setting_data
        attr_reader :call_twice
        attr_reader :explicitly_called
        attr_reader :explicitly_called_with_data

        result_attr :a

        def call
          if call_after_failure
            failure!
            return success!
          end

          if call_after_setting_data
            result[:a] = 1
            return success!
          end

          if call_twice
            success!
            return success!
          end

          return success! if explicitly_called

          return success!(b: 2) if explicitly_called_with_data
        end
      end
    }

    context 'when not explicitly called' do
      it do
        result = klass.call

        expect(result).to be_success
        expect(result).to be_frozen
        expect(result.to_h).to be_empty
        expect(result.to_h).to be_frozen
      end
    end

    context 'when called explicitly' do
      it do
        result = klass.call(explicitly_called: true)

        expect(result).to be_success
        expect(result).to be_frozen
        expect(result.to_h).to be_empty
        expect(result.to_h).to be_frozen
      end
    end

    context 'when called explicitly with data' do
      it do
        result = klass.call(explicitly_called_with_data: true)

        expect(result).to be_success
        expect(result).to be_frozen
        expect(result.to_h).to eql({ b: 2 })
        expect(result.to_h).to be_frozen
      end
    end

    context 'when called after setting data' do
      it do
        result = klass.call(call_after_setting_data: true)

        expect(result).to be_success
        expect(result).to be_frozen
        expect(result.to_h).to eql({ a: 1 })
        expect(result.to_h).to be_frozen
      end
    end

    context 'when called more than once' do
      it do
        expect {
          klass.call(call_twice: true)
        }.to raise_error(FrozenError)
      end
    end

    context 'when called after #failure!' do
      it do
        expect {
          klass.call(call_after_failure: true)
        }.to raise_error(FrozenError)
      end
    end
  end
end
