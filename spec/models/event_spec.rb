require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:rec) { build(:event) }

  describe 'field' do
    it 'is valid with required fields' do
      expect(rec).to be_valid
    end

    it 'is invalid without required fields' do
      rec.event_name = ''
      rec.event_date = nil
      rec.fee = ''
      rec.payment_only = nil

      expect(rec).to_not be_valid
      expect(rec.errors[:event_name]).to include("can't be blank")
      expect(rec.errors[:event_date]).to include("can't be blank")
      expect(rec.errors[:fee]).to include("can't be blank")
      expect(rec.errors[:payment_only]).to include('is not included in the list')
    end

    it 'has default values' do
      rec= Event.new
      expect(rec.fee).to eq(0)
      expect(rec.payment_only).to eq(false)
    end
  end
end
