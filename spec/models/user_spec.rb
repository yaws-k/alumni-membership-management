require 'rails_helper'

RSpec.describe User, type: :model do
  let(:rec) { build(:user) }

  describe 'field' do
    it 'is valid with required fields' do
      expect(rec).to be_valid
    end

    it 'is invalid without required fields' do
      rec.email = ''
      rec.sign_in_count = nil
      rec.failed_attempts = nil
      rec.unreachable = nil

      expect(rec).to_not be_valid
      expect(rec.errors[:email]).to include("can't be blank")
      expect(rec.errors[:sign_in_count]).to include("can't be blank")
      expect(rec.errors[:failed_attempts]).to include("can't be blank")
      expect(rec.errors[:unreachable]).to include('is not included in the list')
    end

    it 'has default values' do
      rec = User.new
      expect(rec.email).to eq('')
      expect(rec.encrypted_password).to eq('')
      expect(rec.sign_in_count).to eq(0)
      expect(rec.failed_attempts).to eq(0)
      expect(rec.unreachable).to eq(false)
    end
  end
end
