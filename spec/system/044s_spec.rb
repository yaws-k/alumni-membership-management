require 'rails_helper'

RSpec.describe '044s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  RSpec.shared_examples '044 reject event creation' do
    before { click_link('イベント一覧', href: events_path) }

    it 'does not show link to create event' do
      expect(page).to_not have_link('イベント追加', href: new_event_path)
    end

    it 'rejects access to new event page' do
      visit new_event_path
      expect(current_path).to eq(redirected_path)
    end
  end

  context 'normal user' do
    let(:redirected_path) { member_path(member) }
    include_context 'login'

    it_behaves_like '044 reject event creation'
  end

  context 'lead' do
    let(:redirected_path) { members_path }
    include_context 'login as lead'

    it_behaves_like '044 reject event creation'
  end

  context 'board' do
    include_context 'login as board'
    before do
      click_link('イベント一覧', href: events_path)
      click_link('イベント追加', href: new_event_path)
    end

    it 'shows fields for new event' do
      expect(current_path).to eq(new_event_path)
      expect(page).to have_field('event_event_name')
      expect(page).to have_field('event_event_date')
      expect(page).to have_field('event_fee')
      expect(page).to have_field('event_note')
    end

    it 'is possible to create new event' do
      fill_in('event_event_name', with: '新規イベント')
      fill_in('event_event_date', with: '2024-08-31')
      fill_in('event_note', with: 'event note')
      click_button('送信')

      within(id: dom_id(Event.find_by(event_name: '新規イベント'))) do
        expect(current_path).to eq(events_path)
        expect(page).to have_text('新規イベント')
        expect(page).to have_text('2024-08-31')
        expect(page).to have_text('event note')
      end
    end
  end
end
