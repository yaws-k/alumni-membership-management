require 'rails_helper'

RSpec.describe '040s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  RSpec.shared_examples '040 roles not shown' do
    context 'new user' do
      before { click_link('メンバー追加', href: new_member_path) }

      it 'does not show role checkboxes' do
        expect(current_path).to eq(new_member_path)
        expect(page).to_not have_selector('table', id: 'roles')
      end
    end
  end

  context 'lead' do
    include_context 'login as lead'
    it_behaves_like '040 roles not shown'
  end

  context 'board' do
    include_context 'login as board'
    it_behaves_like '040 roles not shown'
  end

  context 'admin' do
    include_context 'login as admin'

    context 'new user' do
      before { click_link('メンバー追加', href: new_member_path) }

      it 'shows role checkboxes' do
        expect(current_path).to eq(new_member_path)
        expect(page).to have_selector('table', id: 'roles')
        within(id: 'roles') do
          expect(page).to have_field('member_roles_lead')
          expect(page).to have_field('member_roles_board')
          expect(page).to have_field('member_roles_admin')
        end
      end
    end

    context 'edit user' do
      let(:member2) { create(:member) }
      before do
        click_link('詳細', href: member_path(member))
        click_link('基本情報編集・削除', href: edit_member_path(member))
      end

      it 'shows role checkboxes' do
        expect(current_path).to eq(edit_member_path(member))
        within(id: 'roles') do
          expect(page).to have_field('member_roles_lead')
          expect(page).to have_field('member_roles_board')
          expect(page).to have_field('member_roles_admin')
        end
      end
    end
  end
end
