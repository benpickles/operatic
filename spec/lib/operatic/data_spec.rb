RSpec.describe Operatic::Data do
  describe '.define' do
    let(:data) { klass.new }
    let(:klass) { described_class.define(:stuff, :nonsense) }

    it 'creates a subclass with specified data accessors' do
      data.stuff = 1
      data.nonsense = 2

      expect(data.nonsense).to eql(2)
      expect(data.stuff).to eql(1)
      expect(data.to_h).to eql({ nonsense: 2, stuff: 1 })

      expect(data).not_to respond_to(:foo)
      data[:foo] = 3
      expect(data.to_h).to eql({ foo: 3, nonsense: 2, stuff: 1 })
    end
  end

  describe '#[]= / #[]' do
    let(:data) { described_class.new }

    it 'sets and gets data' do
      data[:a] = 1
      data[:b] = 2

      expect(data[:a]).to be(1)
      expect(data[:b]).to be(2)
      expect(data.to_h).to eql({ a: 1, b: 2 })
    end
  end

  describe '#merge' do
    context 'when passed a hash' do
      let(:data) { described_class.new(a: 1, b: 2) }

      it 'returns a new instance with the merged data' do
        other = data.merge({ b: 3, c: 4 })

        expect(data[:b]).to eql(2)
        expect(data[:c]).to be_nil

        expect(other).to be_a(described_class)
        expect(other).not_to be(data)
        expect(other[:a]).to eql(1)
        expect(other[:b]).to eql(3)
        expect(other[:c]).to eql(4)
      end
    end

    context 'when called on a subclass' do
      let(:data) { klass.new(a: 1) }
      let(:klass) { described_class.define(:b) }

      it 'returns an object of the same class' do
        data.b = 2

        other = data.merge({ b: 3, c: 4 })

        expect(data.b).to eql(2)
        expect(data[:c]).to be_nil

        expect(other).to be_a(klass)
        expect(other).not_to be(data)
        expect(other.b).to eql(3)
        expect(other[:a]).to eql(1)
        expect(other[:b]).to eql(3)
        expect(other[:c]).to eql(4)
      end
    end
  end
end
