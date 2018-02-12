describe OldPlaid::Category do
  context 'when a single category is found' do
    let(:category) { OldPlaid.category('17001013') }
    it { expect(category).to be_kind_of(OldPlaid::Category) }
  end

  context 'when all categories are found' do
    let(:category) { OldPlaid.category }
    it { expect(category).to be_kind_of(Array)}
  end

  context 'when category is not found' do
    it { expect { OldPlaid.category('dumb_cat') }.to raise_error(OldPlaid::NotFound, 'unable to find category') }
  end

end
