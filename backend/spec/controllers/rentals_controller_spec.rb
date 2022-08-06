# frozen_string_literal: true

describe Drivy::RentalsController do
  describe '.save_rentals' do
    subject(:save_rentals) do
      described_class.save_rentals(
        input_path: input_path,
        output_path: output_path
      )
    end

    let(:input_path) { 'input_path.json' }
    let(:output_path) { 'output_path.json' }
    let(:input_json) { { 'cars' => [car_json], 'rentals' => [rental_json] } }
    let(:input_data) { input_json.to_json }
    let(:car_json) { { 'id' => 1, 'price_per_day' => 2000, 'price_per_km' => 10 } }
    let(:rental_json) do
      { 'id' => 1,
        'car_id' => 1,
        'distance' => 100,
        'start_date' => start_date,
        'end_date' => '2017-12-10' }
    end
    let(:start_date) { '2017-12-8' }

    before do
      allow(File).to receive(:read).and_return(input_data)
      allow(File).to receive(:write)
    end

    shared_examples 'reads input file' do
      it 'reads input file' do
        save_rentals

        expect(File).to have_received(:read).with(input_path)
      end
    end

    shared_examples 'processes invalid input' do
      it 'does not write to output file' do
        save_rentals

        expect(File).not_to have_received(:write)
      end

      it 'logs failure to stdout' do
        expect { save_rentals }.to output(/FAILED/).to_stdout
      end
    end

    context 'when correct input data' do
      it 'writes correct data' do
        save_rentals

        expect(File).to have_received(:write).with(
          output_path, '{"rentals":[{"id":1,"price":7000}]}'
        )
      end

      it 'logs success to stdout' do
        expect { save_rentals }.to output(/SUCCESSFULLY FINISHED/).to_stdout
      end

      it 'logs output file to stdout' do
        expect { save_rentals }.to output(/RESULTS FILE: output_path.json/).to_stdout
      end

      it_behaves_like 'reads input file'
    end

    context 'when incorect input data' do
      context 'when invalid date' do
        let(:start_date) { 'invalid' }

        it_behaves_like 'reads input file'
        it_behaves_like 'processes invalid input'
      end

      context 'when invalid car data' do
        let(:car_json) { { 'invalid' => 'invalid' } }

        it_behaves_like 'reads input file'
        it_behaves_like 'processes invalid input'
      end

      context 'when invalid rental data' do
        let(:rental_json) { { 'invalid' => 'invalid' } }

        it_behaves_like 'reads input file'
        it_behaves_like 'processes invalid input'
      end

      context 'when file contains invalid json' do
        let(:input_data) { 'invalid' }

        it_behaves_like 'reads input file'
        it_behaves_like 'processes invalid input'
      end
    end
  end
end
