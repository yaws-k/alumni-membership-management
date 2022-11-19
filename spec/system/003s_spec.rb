require 'rails_helper'

RSpec.describe '003s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'
  include_context 'login'

  RSpec.shared_examples 'edit member' do
    before { visit edit_member_path(member) }

    context 'check fields' do
      it 'shows member edit link' do
        visit member_path(member)
        expect(page).to have_link('基本情報編集・削除', href: edit_member_path(member))
      end

      it 'shows graduate year select' do
        expect(page).to have_select('member_year_id')
      end

      it 'shows name edit fields' do
        expect(page).to have_field('member_family_name_phonetic')
        expect(page).to have_field('member_first_name_phonetic')
        expect(page).to have_field('member_maiden_name_phonetic')
        expect(page).to have_field('member_family_name')
        expect(page).to have_field('member_first_name')
        expect(page).to have_field('member_maiden_name')
      end

      it 'shows communication select' do
        expect(page).to have_select('member_communication')
      end

      it 'shows other additional information edit fields' do
        expect(page).to have_field('member_quit_reason')
        expect(page).to have_field('member_occupation')
        expect(page).to have_field('member_note')
      end
    end

    context 'update and redirect' do
      it 'redirects to member detail page' do
        fill_in('member_family_name_phonetic', with: 'Edited family name')
        click_button('送信')
        expect(current_path).to eq(member_path(member))
      end
    end

    context 'phonetic fields' do
      it 'accepts only Hiragana for phonetics' do
        fill_in('member_family_name_phonetic', with: '漢字')
        fill_in('member_first_name_phonetic', with: 'なまえ）')
        fill_in('member_maiden_name_phonetic', with: 'きゅう　せい')
        click_button('送信')

        expect(page).to have_text('名字の読み仮名に漢字や記号が入っています。')
        expect(page).to have_text('名前の読み仮名に漢字や記号が入っています。')
        expect(page).to have_text('旧姓の読み仮名に漢字や記号が入っています。')
      end

      it 'converts phonetics before save' do
        fill_in('member_family_name_phonetic', with: '？')
        fill_in('member_first_name_phonetic', with: 'ｷｭｳｾｲ')
        fill_in('member_maiden_name_phonetic', with: ' ナマエＡＢＣ')
        click_button('送信')

        member.reload
        expect(page).to have_text('？？？？？')
        expect(page).to have_text('きゅうせい')
        expect(page).to have_text('なまえABC')
      end
    end

    context 'name fields' do
      it 'rejects special characters' do
        fill_in('member_family_name', with: '名字(')
        fill_in('member_first_name', with: '名　前')
        fill_in('member_maiden_name', with: '（旧姓）')
        click_button('送信')

        expect(page).to have_text('名字に記号など不正な文字が入っています。')
        expect(page).to have_text('名前に記号など不正な文字が入っています。')
        expect(page).to have_text('旧姓に記号など不正な文字が入っています。')
      end

      it 'converts names before save' do
        fill_in('member_family_name', with: '名字?')
        fill_in('member_first_name', with: 'ｶﾀｶﾅ')
        fill_in('member_maiden_name', with: ' 旧姓 ')
        click_button('送信')

        expect(page).to have_text('？？？？？')
        expect(page).to have_text('カタカナ')
        expect(page).to have_text('旧姓')
      end
    end
  end

  context 'normal user' do
    it_behaves_like 'edit member'
  end

  context 'lead' do
    before { member.update(roles: %w[lead]) }

    it_behaves_like 'edit member'
  end

  context 'board' do
    before { member.update(roles: %w[board]) }

    it_behaves_like 'edit member'
  end

  context 'admin' do
    before { member.update(roles: %w[admin]) }

    it_behaves_like 'edit member'
  end
end
