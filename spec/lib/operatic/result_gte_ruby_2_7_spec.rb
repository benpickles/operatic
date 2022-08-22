RSpec.describe Operatic::Result do
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
