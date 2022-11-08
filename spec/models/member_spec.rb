require 'rails_helper'

RSpec.describe Member, type: :model do
  let(:rec) { build(:member, :full_fields) }

  describe 'field' do
    it 'is valid with required fields' do
      expect(rec).to be_valid
    end

    it 'is invalid without required fields' do
      rec.family_name_phonetic = ''
      rec.first_name_phonetic = ''
      rec.family_name = ''
      rec.first_name = ''
      rec.communication = ''

      expect(rec).to_not be_valid
      expect(rec.errors[:family_name_phonetic]).to include("can't be blank")
      expect(rec.errors[:first_name_phonetic]).to include("can't be blank")
      expect(rec.errors[:family_name]).to include("can't be blank")
      expect(rec.errors[:first_name]).to include("can't be blank")
      expect(rec.errors[:communication]).to include("can't be blank")
    end

    it 'has default values' do
      expect(Member.new.communication).to eq('メール')
    end
  end

  describe 'method' do
    context 'without mainden name' do
      it 'automatically generates search_key' do
        rec.family_name_phonetic = 'みょうじ'
        rec.maiden_name_phonetic = nil
        rec.first_name_phonetic = 'なまえ'
        rec.family_name = '名字'
        rec.maiden_name = nil
        rec.first_name = '名前'
        expect(rec.search_key).to eq(nil)

        rec.valid?
        expect(rec.search_key).to eq('みょうじなまえ名字名前')
      end
    end

    context 'with mainden name' do
      it 'automatically generates search_key' do
        rec.family_name_phonetic = 'みょうじ'
        rec.maiden_name_phonetic = 'きゅうせい'
        rec.first_name_phonetic = 'なまえ'
        rec.family_name = '名字'
        rec.maiden_name = '旧姓'
        rec.first_name = '名前'
        expect(rec.search_key).to eq(nil)

        rec.valid?
        expect(rec.search_key).to eq('みょうじきゅうせいなまえ名字旧姓名前')
      end
    end
  end
end
