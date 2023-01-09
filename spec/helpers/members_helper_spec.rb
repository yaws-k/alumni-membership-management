require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the MembersHelper. For example:
#
# describe MembersHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe MembersHelper, type: :helper do
  describe 'event_presence' do
    it 'returns presence in Japanese' do
      expect(helper.event_presence(true)).to eq('出席')
      expect(helper.event_presence(false)).to eq('欠席')
      expect(helper.event_presence(nil)).to eq('未回答')
    end
  end

  describe 'communication' do
    # Skip (too simple)
  end

  describe 'full_name' do
    let(:rec) do
      create(
        :member,
        family_name: '名字',
        family_name_phonetic: 'みょうじ',
        first_name: '名前',
        first_name_phonetic: 'なまえ'
      )
    end

    context 'with maiden name' do
      it 'returns full name' do
        rec.update(
          maiden_name: 'ミドル',
          maiden_name_phonetic: 'みどる'
        )
        expect(helper.full_name(rec)).to eq(['名字（ミドル）名前', 'みょうじ（みどる）なまえ'])

        rec.update(
          maiden_name: 'ミドル',
          maiden_name_phonetic: ''
        )
        expect(helper.full_name(rec)).to eq(['名字（ミドル）名前', 'みょうじ（）なまえ'])

        rec.update(
          maiden_name: '',
          maiden_name_phonetic: 'みどる'
        )
        expect(helper.full_name(rec)).to eq(['名字（）名前', 'みょうじ（みどる）なまえ'])
      end
    end

    context 'without maiden name' do
      it 'returns full name' do
        rec.update(
          maiden_name: '',
          maiden_name_phonetic: ''
        )
        expect(helper.full_name(rec)).to eq(['名字 名前', 'みょうじ なまえ'])
      end
    end
  end

  describe 'role_name' do
    it 'returns translated name' do
      expect(helper.role_name('lead')).to eq('世話役')
      expect(helper.role_name('board')).to eq('幹事')
      expect(helper.role_name('admin')).to eq('システム管理者')
      expect(helper.role_name('other')).to eq('エラー')
    end
  end

  describe 'payment' do
    # Skip (too simple)
  end


  describe 'sign_in_info' do
    let(:rec) { create(:user) }

    it 'returns None' do
      rec.update(sign_in_count: 0)
      expect(helper.sign_in_info(rec)).to eq('None')
    end

    it 'returns time and ip' do
      time = Time.now - 60
      rec.update(sign_in_count: 1, current_sign_in_at: time, current_sign_in_ip: '1.2.3.4')
      expect(helper.sign_in_info(rec)).to eq("#{time.localtime} from 1.2.3.4")
    end
  end
end
