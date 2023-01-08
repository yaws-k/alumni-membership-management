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

  describe 'Class method' do
    # Scope
    describe 'accessible_year' do
      let!(:current_user) { create(:user) }
      let!(:member) { current_user.member }
      let!(:year) { member.year }

      let!(:member1) { create(:member, year_id: year.id) }
      let!(:member2) { create(:member) }

      let!(:roles) { { lead: false, board: false, admin: false } }

      context 'normal user' do
        it 'returns no document' do
          expect(Year.accessible_years(roles:, current_user:)).to eq([])
        end
      end

      context 'lead' do
        it 'returns only the same year' do
          roles[:lead] = true
          years = Year.accessible_years(roles:, current_user:)
          expect(years.size).to eq(1)
          expect(years).to eq(Year.where(id: year.id))
        end
      end

      context 'board' do
        it 'returns all years' do
          roles[:board] = true
          years = Year.accessible_years(roles:, current_user:)
          expect(years.size).to eq(2)
          expect(years.to_a).to eq(Year.all.sort(anno_domini: :desc).to_a)
        end
      end

      context 'admin' do
        it 'returns all years' do
          roles[:admin] = true
          years = Year.accessible_years(roles:, current_user:)
          expect(years.size).to eq(2)
          expect(years.to_a).to eq(Year.all.sort(anno_domini: :desc).to_a)
        end
      end
    end
  end
end
