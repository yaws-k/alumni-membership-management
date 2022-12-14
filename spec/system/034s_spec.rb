require 'rails_helper'

RSpec.describe '034s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  context 'board' do
    include_context 'login as board'
    before { click_link('支払い一覧', href: payments_path) }

    it 'is possible to access edit screen' do
      expect(current_path).to eq(payments_path)
      expect(page).to have_link('編集', href: edit_payment_path(payment))
      click_link('編集', href: edit_payment_path(payment))
      expect(current_path).to eq(edit_payment_path(payment))
    end

    it 'shows edit fields' do
      click_link('編集', href: edit_payment_path(payment))
      expect(page).to have_field('event_event_name')
      expect(page).to have_field('event_annual_fee')
      expect(page).to have_field('event_event_date')
      expect(page).to have_field('event_fee')
      expect(page).to have_field('event_note')
    end

    it 'is possible to update payment event' do
      click_link('編集', href: edit_payment_path(payment))
      fill_in('event_fee', with: '123456')
      click_button('送信')

      expect(current_path).to eq(payments_path)
      within(id: dom_id(payment)) do
        expect(page).to have_text('123,456')
      end
    end
  end
end
