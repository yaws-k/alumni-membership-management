require 'rails_helper'

RSpec.describe '005s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'
  include_context 'login'
  let!(:event) { create(:event, :full_fields) }

  RSpec.shared_examples 'event list' do
    before do
      visit member_path(member)
      click_link('イベント一覧', href: events_path)
    end

    it 'shows list of events' do
      expect(page).to have_text(event.event_name)
      expect(page).to have_text(event.event_date)
      expect(page).to have_text(event.fee.to_fs(:delimited))
      expect(page).to have_text(event.note)
      expect(page).to have_link('詳細', href: event_path(event))
    end
  end

  context 'normal user' do
    it_behaves_like 'event list'
    it 'is not possible to edit events' do
      visit member_path(member)
      click_link('イベント一覧', href: events_path)

      within(id: event.id.to_s) do
        expect(page).to_not have_link('編集', href: edit_event_path(event))
        expect(page).to_not have_button('削除')
      end
    end
  end

  context 'lead' do
    before { member.update(roles: %w[lead]) }

    it_behaves_like 'event list'
    it 'is not possible to edit events' do
      visit member_path(member)
      click_link('イベント一覧', href: events_path)

      within(id: event.id.to_s) do
        expect(page).to_not have_link('編集', href: edit_event_path(event))
        expect(page).to_not have_button('削除')
      end
    end
  end

  context 'board' do
    before { member.update(roles: %w[board]) }

    it_behaves_like 'event list'
    it 'is not possible to edit events' do
      visit member_path(member)
      click_link('イベント一覧', href: events_path)

      within(id: event.id.to_s) do
        expect(page).to have_link('編集', href: edit_event_path(event))
        expect(page).to have_button('削除')
      end
    end
  end

  context 'admin' do
    before { member.update(roles: %w[admin]) }

    it_behaves_like 'event list'
    it 'is not possible to edit events' do
      visit member_path(member)
      click_link('イベント一覧', href: events_path)

      within(id: event.id.to_s) do
        expect(page).to have_link('編集', href: edit_event_path(event))
        expect(page).to have_button('削除')
      end
    end
  end
end
