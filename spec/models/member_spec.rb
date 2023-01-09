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

  describe 'Class method' do
    describe 'payment_status' do
      let!(:payment) { create(:event, :annual_fee, event_name: '年会費') }
      let!(:event) { create(:event) }

      let!(:member1) { create(:member) }
      let!(:attendance1) { create(:attendance, :full_fields, event_id: payment.id, member_id: member1.id) }

      let!(:member2) { create(:member, communication: '退会') }
      let!(:attendance2) { create(:attendance, event_id: payment.id, member_id: member2.id) }

      let!(:member3) { create(:member) }

      it 'returns annual fee payment status list' do
        status = Member.payment_status
        expect(status[member1.id]).to eq(attendance1.payment_date)
        expect(status[member2.id]).to eq('-')
        expect(status[member3.id]).to eq('未済')
      end
    end

    describe 'year_sort' do
      let(:rec1) { create(:member) }
      let(:rec2) { create(:member) }
      let(:member_ids) { [rec1.id, rec2.id] }

      before do
        rec1.year.update(anno_domini: 2000)
        rec2.year.update(anno_domini: 2010)
      end

      it 'sorts members by year asc' do
        recs = Member.year_sort(id: member_ids, order: :asc)
        expect(recs.pluck(:id)).to eq([rec1.id, rec2.id])
      end

      it 'sorts members by year desc' do
        recs = Member.year_sort(id: member_ids, order: :desc)
        expect(recs.pluck(:id)).to eq([rec2.id, rec1.id])
      end
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
