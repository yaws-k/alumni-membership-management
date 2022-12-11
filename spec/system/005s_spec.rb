require 'rails_helper'

RSpec.describe '005s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'
  let!(:event) { create(:event, :full_fields, event_date: Date.today + 10) }
  let!(:event2) { create(:event, :full_fields, event_date: Date.today + 20) }

  RSpec.shared_examples '005 event list' do
    before do
      visit member_path(member)
      click_link('イベント一覧', href: events_path)
    end

    it 'shows list of events' do
      within(id: dom_id(event)) do
        expect(page).to have_text(event.event_name)
        expect(page).to have_text(event.event_date)
        expect(page).to have_text(event.fee.to_fs(:delimited))
        expect(page).to have_text(event.note)
        expect(page).to have_link('詳細', href: event_path(event))
      end
    end

    it 'sorts events by event date' do
      array = []
      [event2, event].each { |e| array << "id='#{dom_id(e)}'" }
      regexp = Regexp.new(array.join('.*'), Regexp::MULTILINE)
      expect(page.source).to match(regexp)
    end
  end

  context 'normal user' do
    include_context 'login'

    it_behaves_like '005 event list'

    it 'is not possible to edit events' do
      visit member_path(member)
      click_link('イベント一覧', href: events_path)

      within(id: dom_id(event)) do
        expect(page).to_not have_link('編集', href: edit_event_path(event))
        expect(page).to_not have_button('削除')
      end
    end
  end

  context 'lead' do
    include_context 'login as lead'

    it_behaves_like '005 event list'

    it 'is not possible to edit events' do
      visit member_path(member)
      click_link('イベント一覧', href: events_path)

      within(id: dom_id(event)) do
        expect(page).to_not have_link('編集', href: edit_event_path(event))
        expect(page).to_not have_button('削除')
      end
    end
  end

  context 'board' do
    include_context 'login as board'

    it_behaves_like '005 event list'

    it 'is not possible to edit events' do
      visit member_path(member)
      click_link('イベント一覧', href: events_path)

      within(id: dom_id(event)) do
        expect(page).to have_link('編集', href: edit_event_path(event))
        expect(page).to have_button('削除')
      end
    end
  end

  context 'admin' do
    include_context 'login as admin'

    it_behaves_like '005 event list'

    it 'is not possible to edit events' do
      visit member_path(member)
      click_link('イベント一覧', href: events_path)

      within(id: dom_id(event)) do
        expect(page).to have_link('編集', href: edit_event_path(event))
        expect(page).to have_button('削除')
      end
    end
  end
end
