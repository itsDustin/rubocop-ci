RSpec.describe RubocopCi do
  context '.rubocop_configs' do
    context 'when there are local configs' do
      before do
        RubocopCi::RUBOCOP_KNOWN_CONFIGS.each do |cfg|
          allow(::File).to receive(:exist?).with(cfg).and_return(true)
        end
      end

      let(:configs) { subject.rubocop_local_configs.map { |file| File.basename(file) } }

      it 'returns instance of array' do
        expect(subject.rubocop_local_configs).to be_an_instance_of Array
      end

      it 'contains .rubocop.yml' do
        expect(configs).to include '.rubocop.yml'
      end

      it 'contains .rubocop_todo.yml' do
        expect(configs).to include '.rubocop_todo.yml'
      end
    end

    context 'when there are no local config' do
      it 'returns empty array' do
        expect(subject.rubocop_local_configs).to eq []
      end
    end
  end
end
