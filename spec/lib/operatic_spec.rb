RSpec.describe Operatic do
  describe '.call' do
    context 'when neither #failure! or #success! are explicitly called' do
      let(:klass) {
        Class.new do
          include Operatic
        end
      }

      it 'returns a frozen Success result' do
        result = klass.call

        expect(result).to be_a(Operatic::Success)
        expect(result).not_to be_failure
        expect(result).to be_frozen
        expect(result).to be_success
        expect(result.data).to be_frozen
        expect(result.to_h).to eql({})
        expect(result.to_h).to be_frozen
      end
    end

    context 'when called with something other than kwargs' do
      let(:klass) {
        Class.new do
          include Operatic
        end
      }

      it 'raises ArgumentError', :aggregate_failures do
        expect { klass.call('Dave') }.to raise_error(ArgumentError)
        expect { klass.call(['Dave']) }.to raise_error(ArgumentError)

        if RUBY_VERSION >= '3.1'
          expect { klass.call({ name: 'Dave' }) }.to raise_error(ArgumentError)
        end
      end
    end

    context 'when an error is raised' do
      let(:klass) {
        Class.new do
          include Operatic

          def call
            raise 'foo'
          end
        end
      }

      it 'is left for the consumer to deal with' do
        expect {
          klass.call
        }.to raise_error(RuntimeError, 'foo')
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

    context 'when the operation succeeds' do
      it do
        expect(klass.call!).to be_a(Operatic::Success)
      end
    end

    context 'when the operation fails' do
      it do
        expect {
          klass.call!(oh_no: true)
        }.to raise_error(Operatic::FailureError)
      end
    end
  end

  describe '.data_attr' do
    let(:klass) {
      Class.new do
        include Operatic

        data_attr :a, :b

        def call
          data.a = 1

          success!(
            b: 2,
            c: 3,
          )
        end
      end
    }

    it 'makes the defined attributes available to read on the result' do
      result = klass.call

      expect(result).to be_a(Operatic::Success)
      expect(result).to be_frozen
      expect(result.a).to eql(1)
      expect(result.b).to eql(2)
      expect(result).not_to respond_to(:c)
      expect(result.to_h).to eql({ a: 1, b: 2, c: 3 })
      expect(result.to_h).to be_frozen
    end

    it 'does not affect other result classes' do
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
          success!(message: "Hello #{@name}")
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
            data[:c] = 3
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

        expect(result).to be_a(Operatic::Failure)
        expect(result).to be_frozen
        expect(result.to_h).to eql({})
        expect(result.to_h).to be_frozen
      end
    end

    context 'when called with data' do
      it do
        result = klass.call(early_failure_with_data: true)

        expect(result).to be_a(Operatic::Failure)
        expect(result).to be_frozen
        expect(result.to_h).to eql({ a: 1, b: 2 })
        expect(result.to_h).to be_frozen
      end
    end

    context 'when called after setting data on the result object' do
      it do
        result = klass.call(failure_after_setting_data: true)

        expect(result).to be_a(Operatic::Failure)
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

        data_attr :a

        def call
          if call_after_failure
            failure!
            return success!
          end

          if call_after_setting_data
            data[:a] = 1
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

        expect(result).to be_a(Operatic::Success)
        expect(result).to be_frozen
        expect(result.to_h).to be_empty
        expect(result.to_h).to be_frozen
      end
    end

    context 'when called explicitly' do
      it do
        result = klass.call(explicitly_called: true)

        expect(result).to be_a(Operatic::Success)
        expect(result).to be_frozen
        expect(result.to_h).to be_empty
        expect(result.to_h).to be_frozen
      end
    end

    context 'when called explicitly with data' do
      it do
        result = klass.call(explicitly_called_with_data: true)

        expect(result).to be_a(Operatic::Success)
        expect(result).to be_frozen
        expect(result.to_h).to eql({ b: 2 })
        expect(result.to_h).to be_frozen
      end
    end

    context 'when called after setting data' do
      it do
        result = klass.call(call_after_setting_data: true)

        expect(result).to be_a(Operatic::Success)
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
