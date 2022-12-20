require 'rails_helper'

RSpec.describe '046s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'
  let!(:event) { create(:event) }

  context 'board' do
    include_context 'login as board'
    before { click_link('イベント一覧', href: events_path) }

    context 'nobody applied' do
      it 'is possible to delete event' do
        expect(Event.where(id: event.id).size).to eq(1)
        within(id: dom_id(event)) { click_button('削除') }

        expect(current_path).to eq(events_path)
        expect(page).to have_selector('.alert.alert-info', text: "#{event.event_name}を削除しました。")
        expect(Event.where(id: event.id).size).to eq(0)
      end
    end

    context 'somebody already paid for it' do
      before { create(:attendance, member_id: member.id, event_id: event.id) }

      it 'rejects deletion' do
        expect(Event.where(id: event.id).size).to eq(1)
        within(id: dom_id(event)) { click_button('削除') }

        expect(current_path).to eq(events_path)
        expect(page).to have_selector('.alert.alert-error', text: "参加者がいるため、#{event.event_name}を削除できませんでした。")
        expect(Event.where(id: event.id).size).to eq(1)
      end
    end
  end
end
