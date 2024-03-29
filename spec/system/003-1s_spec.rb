require 'rails_helper'

RSpec.describe '003-1s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  RSpec.shared_examples '003-1 edit member' do
    before do
      visit member_path(member)
      click_link('基本情報編集・削除', href: edit_member_path(member))
    end

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
  end

  context 'normal user' do
    include_context 'login'

    it_behaves_like '003-1 edit member'
  end

  context 'lead' do
    include_context 'login as lead'

    it_behaves_like '003-1 edit member'
  end

  context 'board' do
    include_context 'login as board'

    it_behaves_like '003-1 edit member'
  end

  context 'admin' do
    include_context 'login as admin'

    it_behaves_like '003-1 edit member'
  end
end
