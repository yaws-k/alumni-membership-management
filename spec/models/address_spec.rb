require 'rails_helper'

RSpec.describe Address, type: :model do
  let(:rec) { build(:address) }

  describe 'field' do
    it 'is valid with required fields' do
      expect(rec).to be_valid
    end

    it 'is invalid without required fields' do
      rec.postal_code = ''
      rec.address1 = ''
      rec.unreachable = nil

      expect(rec).to_not be_valid
      expect(rec.errors[:postal_code]).to include("can't be blank")
      expect(rec.errors[:address1]).to include("can't be blank")
      expect(rec.errors[:unreachable]).to include('is not included in the list')
    end

    it 'has default values' do
      expect(Address.new.unreachable).to eq(false)
    end
  end

  describe 'method' do
    context 'normalize' do
      it 'normalize input' do
        rec.postal_code = '１２３ー４５６７'
        rec.address1 = '住所全角数字１ー２３'
        rec.address2 = '部屋番号全角数字４５６なーんとかかんとか'

        rec.valid?
        expect(rec.postal_code).to eq('123-4567')
        expect(rec.address1).to eq('住所全角数字1-23')
        expect(rec.address2).to eq('部屋番号全角数字456なーんとかかんとか')
      end
    end

    context 'postal code validation' do
      it 'adds error to invalid code' do
        rec.postal_code = 'CA12345'

        rec.valid?
        expect(rec.errors[:postal_code]).to include('郵便番号の形式が誤っています。なお、住所は日本国内の形式にしか対応していません。')
      end

      it 'add hyphen when missing' do
        rec.postal_code = '1234567'

        rec.valid?
        expect(rec.postal_code).to eq('123-4567')
      end
    end
  end
end
