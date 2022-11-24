require 'rails_helper'

RSpec.describe '004s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'
  include_context 'login'

  RSpec.shared_examples 'delete user' do
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

  RSpec.shared_examples 'delete address' do
    let!(:address) { create(:address, :full_fields, member_id: member.id) }

    before { visit member_path(member) }

    it 'deletes email' do
      expect(Address.where(id: address.id).size).to eq(1)

      within(id: dom_id(address)) { click_button('削除') }

      expect(current_path).to eq(member_path(member))
      expect(page).to have_text("#{address.postal_code}　#{address.address1}　#{address.address2}を削除しました。")
      expect(Address.where(id: address.id).size).to eq(0)
    end
  end

  context 'normal user' do
    it_behaves_like 'delete user'
    it_behaves_like 'delete address'
  end

  context 'lead' do
    before { member.update(roles: %w[lead]) }

    it_behaves_like 'delete user'
    it_behaves_like 'delete address'
  end

  context 'board' do
    before { member.update(roles: %w[board]) }

    it_behaves_like 'delete user'
    it_behaves_like 'delete address'
  end

  context 'admin' do
    before { member.update(roles: %w[admin]) }

    it_behaves_like 'delete user'
    it_behaves_like 'delete address'
  end
end
