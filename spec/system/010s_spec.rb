require 'rails_helper'

RSpec.describe '010s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'
  include_context 'login'
  let!(:address) { create(:address, :full_fields, member_id: member.id) }

  RSpec.shared_examples 'address' do
    before do
      visit member_path(member)
      click_link('編集', href: edit_member_address_path(member, address))
    end

    it 'converts address' do
      fill_in('address_address1', with: '東京都千代田区有楽町２ー9-17')
      fill_in('address_address2', with: 'カーサなんとか')
      click_button('送信')

      within(id: 'postalAddress') do
        within(id: dom_id(address)) do
          expect(page).to have_text('東京都千代田区有楽町2-9-17')
          expect(page).to have_text('カーサなんとか')
        end
      end
    end
  end

  context 'normal user' do
    it_behaves_like 'address'
  end

  context 'lead' do
    before { member.update(roles: %w[lead]) }

    it_behaves_like 'address'
  end

  context 'board' do
    before { member.update(roles: %w[board]) }

    it_behaves_like 'address'
  end

  context 'admin' do
    before { member.update(roles: %w[admin]) }

    it_behaves_like 'address'
  end
end
