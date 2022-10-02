require 'rails_helper'

RSpec.describe Year, type: :model do
  describe 'field' do
    let(:rec) { build(:year) }

    it 'is valid with required fields' do
      expect(rec).to be_valid
    end

    it 'is invalid without required fields' do
      rec.graduate_year = ''
      rec.anno_domini = nil
      rec.japanese_calendar = ''

      expect(rec).to_not be_valid
      expect(rec.errors[:graduate_year]).to include("can't be blank")
      expect(rec.errors[:anno_domini]).to include("can't be blank")
      expect(rec.errors[:japanese_calendar]).to include("can't be blank")
    end
  end

  describe 'method' do
  end
end
