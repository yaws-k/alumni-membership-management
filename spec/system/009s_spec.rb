require 'rails_helper'

RSpec.describe '009s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'
  include_context 'login'

  RSpec.shared_examples 'phonetics' do
    before do
      visit member_path(member)
      click_link('基本情報編集・削除', href: edit_member_path(member))
    end

    it 'accepts only Hiragana for phonetics' do
      fill_in('member_family_name_phonetic', with: '漢字')
      fill_in('member_first_name_phonetic', with: 'なまえ）')
      fill_in('member_maiden_name_phonetic', with: 'きゅう　せい')
      click_button('送信')

      within(class: 'alert alert-error') do
        expect(page).to have_text('名字の読み仮名に漢字や記号が入っています。')
        expect(page).to have_text('名前の読み仮名に漢字や記号が入っています。')
        expect(page).to have_text('旧姓の読み仮名に漢字や記号が入っています。')
      end
    end

    it 'converts phonetics before save' do
      fill_in('member_family_name_phonetic', with: '？')
      fill_in('member_first_name_phonetic', with: 'ｷｭｳｾｲ?')
      fill_in('member_maiden_name_phonetic', with: ' ナマエＡＢＣﾅﾏｴ')
      click_button('送信')

      within(id: 'basicData') do
        expect(page).to have_text('？？？？？')
        expect(page).to have_text('？？？？？')
        expect(page).to have_text('なまえABCなまえ')
      end
    end
  end

  context 'normal user' do
    it_behaves_like 'phonetics'
  end

  context 'lead' do
    before { member.update(roles: %w[lead]) }

    it_behaves_like 'phonetics'
  end

  context 'board' do
    before { member.update(roles: %w[board]) }

    it_behaves_like 'phonetics'
  end

  context 'admin' do
    before { member.update(roles: %w[admin]) }

    it_behaves_like 'phonetics'
  end
end
