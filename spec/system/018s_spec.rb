require 'rails_helper'

RSpec.describe '018s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  let!(:member1) { create(:member, :full_fields, year_id: member.year_id) }
  let!(:user1) { create(:user, member_id: member1.id) }
  let!(:address1) { create(:address, member_id: member1.id) }
  let!(:member2) { create(:member) }
  let!(:user2) { create(:user, member_id: member2.id) }

  RSpec.shared_examples '018 normal user' do
    it 'rejects to access the same year member edit page' do
      visit edit_member_path(member1)
      expect(current_path).to eq(member_path(member))
    end

    it 'rejects to access different year member edit page' do
      visit edit_member_path(member2)
      expect(current_path).to eq(member_path(member))
    end
  end

  RSpec.shared_examples '018 lead' do
    before do
      click_link('詳細', href: member_path(member1))
      expect(current_path).to eq(member_path(member1))
    end

    it 'is possible to delete email' do
      expect(member1.users.size).to eq(1)
      within(id: dom_id(user1)) { click_button('削除') }

      expect(current_path).to eq(member_path(member1))
      expect(page).to have_text("#{user1.email}を削除しました。")
      expect(member1.users.size).to eq(0)
    end

    it 'is possible to delete address' do
      expect(member1.addresses.size).to eq(1)
      within(id: dom_id(address1)) { click_button('削除') }

      expect(current_path).to eq(member_path(member1))
      expect(page).to have_text("#{address1.postal_code}　#{address1.address1}　#{address1.address2}を削除しました。")
      expect(member1.addresses.size).to eq(0)
    end

    it 'is possible to delete member' do
      click_link('基本情報編集・削除', href: edit_member_path(member1))
      click_button('削除')

      expect(current_path).to eq(members_path)
      expect(Member.where(id: member1.id).size).to eq(0)
      expect(page).to_not have_selector(id: dom_id(member1))
    end
  end

  context 'normal user' do
    include_context 'login'
    it_behaves_like '018 normal user'
  end

  context 'lead' do
    before { member.update(roles: %w[lead]) }
    include_context 'login'
    it_behaves_like '018 lead'
  end
end
