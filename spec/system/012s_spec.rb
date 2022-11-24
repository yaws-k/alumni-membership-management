require 'rails_helper'

RSpec.describe '012s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'
  include_context 'login'
  let!(:address) { create(:address, :full_fields, member_id: member.id) }

  RSpec.shared_examples 'postal code' do
    before do
      visit member_path(member)
      click_link('編集', href: edit_member_address_path(member, address))
    end

    it 'converts postal code (1)' do
      fill_in('address_postal_code', with: '１００ー0005')
      click_button('送信')

      within(id: 'postalAddress') do
        expect(page).to have_text('100-0005')
      end
    end

    it 'converts postal code (2)' do
      fill_in('address_postal_code', with: '１００0005')
      click_button('送信')

      within(id: 'postalAddress') do
        expect(page).to have_text('100-0005')
      end
    end
  end

  context 'normal user' do
    it_behaves_like 'postal code'
  end

  context 'lead' do
    before { member.update(roles: %w[lead]) }

    it_behaves_like 'postal code'
  end

  context 'board' do
    before { member.update(roles: %w[board]) }

    it_behaves_like 'postal code'
  end

  context 'admin' do
    before { member.update(roles: %w[admin]) }

    it_behaves_like 'postal code'
  end
end
