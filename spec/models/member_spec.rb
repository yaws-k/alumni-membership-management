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

  describe 'phonetic_valid?' do
    it 'is valid only with Hiragana' do
      rec.family_name_phonetic = 'よみ()'
      rec.first_name_phonetic = '漢字'
      rec.maiden_name_phonetic = '漢　字'

      expect(rec).to_not be_valid
      expect(rec.errors[:family_name_phonetic]).to include('名字の読み仮名に漢字や記号が入っています。')
      expect(rec.errors[:first_name_phonetic]).to include('名前の読み仮名に漢字や記号が入っています。')
      expect(rec.errors[:maiden_name_phonetic]).to include('旧姓の読み仮名に漢字や記号が入っています。')
    end

    it 'is valid with Hiragana' do
      rec.family_name_phonetic = 'みょうじ'
      rec.first_name_phonetic = 'なまえ'
      rec.maiden_name_phonetic = 'きゅうせい'

      expect(rec).to be_valid
    end
  end

  describe 'name_valid?' do
    it 'is invalid with special characters' do
      rec.family_name = '名字()'
      rec.first_name = '名　前'
      rec.maiden_name = '（旧姓）'

      expect(rec).to_not be_valid
      expect(rec.errors[:family_name]).to include('名字に記号など不正な文字が入っています。')
      expect(rec.errors[:first_name]).to include('名前に記号など不正な文字が入っています。')
      expect(rec.errors[:maiden_name]).to include('旧姓に記号など不正な文字が入っています。')
    end
  end

  describe 'private method' do
    describe 'generate_search_key' do
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

    describe 'normalize_phonetics' do
      it 'normalize phonetics' do
        rec = build(:member)
        rec.family_name_phonetic = '?'
        rec.maiden_name_phonetic = nil
        rec.first_name_phonetic = 'ナマエ'
        rec.save

        expect(rec.family_name_phonetic).to eq('？？？？？')
        expect(rec.maiden_name_phonetic).to eq('')
        expect(rec.first_name_phonetic).to eq('なまえ')
      end
    end

    describe 'normalize_names' do
      it 'normalize phonetics' do
        rec = build(:member)
        rec.family_name = '名字?'
        rec.maiden_name = 'ｶﾀｶﾅ'
        rec.first_name = ' 名前 '
        rec.save

        expect(rec.family_name).to eq('？？？？？')
        expect(rec.maiden_name).to eq('カタカナ')
        expect(rec.first_name).to eq('名前')
      end
    end
  end
end
