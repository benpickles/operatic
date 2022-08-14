RSpec.describe Operatic::Result do
  describe '.generate' do
    let(:klass) { described_class.generate(:data, :stuff) }
    let(:result) { klass.new }

    it 'creates a Result subclass with specified data accessors' do
      result.data = 1
      result.stuff = 2

      expect(result.data).to eql(1)
      expect(result.stuff).to eql(2)
      expect(result).not_to respond_to(:c)
      expect(result.to_h).to eql({ data: 1, stuff: 2 })

      result[:c] = 3

      expect(result.to_h).to eql({ data: 1, stuff: 2, c: 3 })
    end
  end

  describe '#[]= / #[]' do
    let(:result) { described_class.new }

    it 'sets and gets data' do
      result[:a] = 1
      result[:b] = 2

      expect(result[:a]).to be(1)
      expect(result[:b]).to be(2)
      expect(result.to_h).to eql({ a: 1, b: 2 })
    end
  end

  if RUBY_VERSION >= '2.7'
    describe '#deconstruct (pattern matching)' do
      it do
        result = described_class.new.failure!(a: 1, b: 2)

        deconstructed = case result
        in [success, { a: }]
          [success, a]
        end

        expect(deconstructed).to eql([false, 1])
      end
    end
  end

  describe '#failure!' do
    let(:result) { described_class.new }

    it 'marks itself as a failure, sets data, and freezes itself' do
      result.failure!(a: 1, b: 2)

      expect(result).to be_failure
      expect(result).to be_frozen
      expect(result.to_h).to eql({ a: 1, b: 2 })
      expect(result.to_h).to be_frozen
    end
  end

  describe '#success!' do
    let(:result) { described_class.new }

    it 'marks itself as a success, sets data, and freezes itself' do
      result.success!(a: 1, b: 2)

      expect(result).to be_success
      expect(result).to be_frozen
      expect(result.to_h).to eql({ a: 1, b: 2 })
      expect(result.to_h).to be_frozen
    end
  end
end
