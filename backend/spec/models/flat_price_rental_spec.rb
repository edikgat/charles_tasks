# frozen_string_literal: true

describe Drivy::FlatPriceScaleRental do
  subject(:rental) { described_class.new(model_data) }

  let(:model_data) do
    {
      id: id,
      car_id: car_id,
      start_date: start_date,
      end_date: end_date,
      distance: distance
    }
  end
  let(:id) { 1 }
  let(:car_id) { 1 }
  let(:distance) { 2 }
  let(:start_date) { Date.today }
  let(:end_date) { Date.today + 10 }

  before do
    Drivy::Car.create(
      id: 1,
      price_per_day: 1000,
      price_per_km: 20
    )
  end

  describe '#price' do
    it 'returns expected price' do
      expect(rental.price).to eq(11_040)
    end
  end

  describe '#price_details' do
    it 'calculates fee' do
      expect(rental.price_details.total_fee).to eq(3312)
    end
  end

  describe '#payment_actions' do
    it 'returns payment actions' do
      expect(rental.payment_actions.driver).to eq(
        amount: 11_040,
        type: :debit,
        who: :driver
      )
    end
  end

  it_behaves_like 'rental model'
end
