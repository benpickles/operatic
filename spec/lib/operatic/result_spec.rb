RSpec.describe Operatic::Result do
  describe '.generate' do
    let(:klass) { described_class.generate(:a, :b) }
    let(:result) { klass.new }

    it 'creates a Result subclass with specified data accessors' do
      result.a = 1
      result.b = 2

      expect(result.a).to eql(1)
      expect(result.b).to eql(2)
      expect(result).not_to respond_to(:c)
      expect(result.data).to eql({ a: 1, b: 2 })

      result.data[:c] = 3

      expect(result.data).to eql({ a: 1, b: 2, c: 3 })
    end
  end

  describe '#failure' do
    let(:result) { described_class.new }

    it 'marks itself as a failure, sets data, and freezes itself' do
      result.failure!(a: 1, b: 2)

      expect(result).to be_failure
      expect(result).to be_frozen
      expect(result.data).to eql({ a: 1, b: 2 })
      expect(result.data).to be_frozen
    end
  end

  describe '#success' do
    let(:result) { described_class.new }

    it 'marks itself as a success, sets data, and freezes itself' do
      result.success!(a: 1, b: 2)

      expect(result).to be_success
      expect(result).to be_frozen
      expect(result.data).to eql({ a: 1, b: 2 })
      expect(result.data).to be_frozen
    end
  end
end
