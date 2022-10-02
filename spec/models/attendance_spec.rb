require 'rails_helper'

RSpec.describe Attendance, type: :model do
  let(:rec) { build(:attendance) }

  describe 'field' do
    it 'is valid with required fields' do
      expect(rec).to be_valid
    end

    it 'is invalid without required fields' do
      rec.amount = nil

      expect(rec).to_not be_valid
      expect(rec.errors[:amount]).to include("can't be blank")
    end

    it 'has default values' do
      rec = Attendance.new
      expect(rec.application).to eq(nil)
      expect(rec.presence).to eq(nil)
      expect(rec.amount).to eq(0)
    end
  end
end
