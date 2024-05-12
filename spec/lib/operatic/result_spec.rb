RSpec.describe Operatic::Result do
  describe '#[]' do
    subject { described_class.new(data) }

    let(:data) { Operatic::Data.new(a: 1, b: 2) }

    it 'reads the key from its data object' do
      expect(subject[:a]).to be(1)
      expect(subject[:b]).to be(2)
    end
  end

  describe '#deconstruct (pattern matching)' do
    subject { Operatic::Success.new(data) }

    let(:data) { Operatic::Data.new(a: 1, b: 2) }

    it 'returns a tuple of itself and its data' do
      deconstructed = case subject
      in [Operatic::Success, { a: }]
        [true, a]
      end

      expect(deconstructed).to eql([true, 1])
    end
  end

  describe '#deconstruct_keys (pattern matching)' do
    subject { described_class.new(data) }

    let(:data) { Operatic::Data.new(a: 1, b: 2, c: 3) }

    it 'matches against its data' do
      deconstructed = case subject
      in a:, c:
        [a, c]
      end

      expect(deconstructed).to eql([1, 3])
    end
  end

  describe '#method_missing / #respond_to?' do
    subject { described_class.new(data) }

    let(:data) { Operatic::Data.define(:a).new(a: 1, b: 2) }

    it 'forwards to methods defined on its data object' do
      expect(subject.respond_to?(:a)).to be(true)
      expect(subject.a).to eql(1)

      expect(subject.respond_to?(:b)).to be(false)
      expect { subject.b }.to raise_error(NoMethodError)
    end

    it 'forwards all arguments' do
      def data.foo(*args, **kwargs, &block)
        yield(args, kwargs)
      end

      returned = subject.foo(1, 2, a: 1, b: 2) do |args, kwargs|
        [args, kwargs]
      end

      expect(returned).to eql([
        [1, 2],
        { a: 1, b: 2 },
      ])
    end
  end
end
