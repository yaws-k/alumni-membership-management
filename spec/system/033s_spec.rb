require 'rails_helper'

RSpec.describe '033s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  context 'board' do
    include_context 'login as board'
    before do
      click_link('支払い一覧', href: payments_path)
      click_link('支払い追加', href: new_payment_path)
    end

    it 'shows fields for payment' do
      expect(current_path).to eq(new_payment_path)
      expect(page).to have_field('event_event_name')
      expect(page).to have_field('event_annual_fee')
      expect(page).to have_field('event_event_date')
      expect(page).to have_field('event_fee')
      expect(page).to have_field('event_note')
    end

    it 'is possible to create new payment event' do
      fill_in('event_event_name', with: '2023寄付')
      fill_in('event_event_date', with: '2024-08-31')
      fill_in('event_note', with: 'event note')
      click_button('送信')

      within(id: dom_id(Event.find_by(event_name: '2023寄付'))) do
        expect(current_path).to eq(payments_path)
        expect(page).to have_text('2023寄付')
        expect(page).to have_text('2024-08-31')
        expect(page).to have_text('event note')
      end
    end

    it 'is possible to create new annual fee' do
      fill_in('event_event_name', with: '2023年会費')
      check('event_annual_fee')
      fill_in('event_event_date', with: '2024-08-31')
      fill_in('event_note', with: 'event note')
      click_button('送信')

      within(id: dom_id(Event.find_by(event_name: '2023年会費'))) do
        expect(current_path).to eq(payments_path)
        expect(page).to have_text('2023年会費')
        expect(page).to have_text('✔')
        expect(page).to have_text('2024-08-31')
        expect(page).to have_text('event note')
      end
    end
  end
end
