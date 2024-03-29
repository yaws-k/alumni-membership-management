require 'rails_helper'

RSpec.describe '004s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  RSpec.shared_examples '004 delete user' do
    let!(:user2) { create(:user, member_id: member.id) }

    before { visit member_path(member) }

    it 'deletes email' do
      expect(User.where(id: user2.id).size).to eq(1)

      within(id: dom_id(user2)) { click_button('削除') }

      expect(current_path).to eq(member_path(member))
      expect(page).to have_text("#{user2.email}を削除しました。")
      expect(User.where(id: user2.id).size).to eq(0)
    end
  end

  RSpec.shared_examples '004 delete address' do
    let!(:address) { create(:address, :full_fields, member_id: member.id) }

    before { visit member_path(member) }

    it 'deletes address' do
      expect(Address.where(id: address.id).size).to eq(1)

      within(id: dom_id(address)) { click_button('削除') }

      expect(current_path).to eq(member_path(member))
      expect(page).to have_text("#{address.postal_code}　#{address.address1}　#{address.address2}を削除しました。")
      expect(Address.where(id: address.id).size).to eq(0)
    end
  end

  context 'normal user' do
    include_context 'login'

    it_behaves_like '004 delete user'
    it_behaves_like '004 delete address'

    it 'does not show member delete button' do
      click_link('基本情報編集・削除', href: edit_member_path(member))
      expect(page).to_not have_button('削除')
    end
  end

  context 'lead' do
    include_context 'login as lead'

    it_behaves_like '004 delete user'
    it_behaves_like '004 delete address'
  end

  context 'board' do
    include_context 'login as board'

    it_behaves_like '004 delete user'
    it_behaves_like '004 delete address'
  end

  context 'admin' do
    include_context 'login as admin'

    it_behaves_like '004 delete user'
    it_behaves_like '004 delete address'
  end
end
