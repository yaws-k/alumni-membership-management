require 'rails_helper'

RSpec.describe '045s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'
  let!(:event) { create(:event) }

  context 'board' do
    include_context 'login as board'
    before { click_link('イベント一覧', href: events_path) }

    it 'is possible to access edit screen' do
      expect(current_path).to eq(events_path)
      expect(page).to have_link('編集', href: edit_event_path(event))
      click_link('編集', href: edit_event_path(event))
      expect(current_path).to eq(edit_event_path(event))
    end

    it 'shows edit fields' do
      click_link('編集', href: edit_event_path(event))
      expect(page).to have_field('event_event_name')
      expect(page).to have_field('event_event_date')
      expect(page).to have_field('event_fee')
      expect(page).to have_field('event_note')
    end

    it 'is possible to update event' do
      click_link('編集', href: edit_event_path(event))
      fill_in('event_fee', with: '123456')
      click_button('送信')

      expect(current_path).to eq(events_path)
      within(id: dom_id(event)) do
        expect(page).to have_text('123,456')
      end
    end
  end
end
