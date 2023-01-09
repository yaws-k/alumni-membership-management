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
      rec.annual_fee = nil

      expect(rec).to_not be_valid
      expect(rec.errors[:event_name]).to include("can't be blank")
      expect(rec.errors[:event_date]).to include("can't be blank")
      expect(rec.errors[:fee]).to include("can't be blank")
      expect(rec.errors[:payment_only]).to include('is not included in the list')
      expect(rec.errors[:annual_fee]).to include('is not included in the list')
    end

    it 'has default values' do
      rec = Event.new
      expect(rec.fee).to eq(0)
      expect(rec.payment_only).to eq(false)
    end
  end

  describe 'method' do
    describe 'sorted' do
      let!(:rec1) { create(:event, event_date: Date.today) }
      let!(:rec2) { create(:event, event_date: Date.today + 1) }
      let!(:rec3) { create(:event, event_date: Date.today + 2) }
      let!(:rec4) { create(:event, event_date: Date.today, payment_only: true) }
      let!(:rec5) { create(:event, event_date: Date.today + 1, payment_only: true) }

      it 'returns normal events' do
        recs = Event.sorted(payment_only: false)
        expect(recs.size).to eq(3)
        expect(recs.pluck(:event_date)).to eq([rec3.event_date, rec2.event_date, rec1.event_date])
      end

      it 'returns payments' do
        recs = Event.sorted(payment_only: true)
        expect(recs.size).to eq(2)
        expect(recs.pluck(:event_date)).to eq([rec5.event_date, rec4.event_date])
      end
    end
  end
end
