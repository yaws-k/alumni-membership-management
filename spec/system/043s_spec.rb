require 'rails_helper'

RSpec.describe '043s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  context 'board' do
    include_context 'login as board'
    before { click_link('支払い一覧', href: payments_path) }

    context 'nobody paid for it' do
      it 'is possible to delete payment event' do
        expect(Event.where(id: payment.id).size).to eq(1)
        within(id: dom_id(payment)) { click_button('削除') }

        expect(current_path).to eq(payments_path)
        expect(page).to have_selector('.alert.alert-info', text: "#{payment.event_name}を削除しました。")
        expect(Event.where(id: payment.id).size).to eq(0)
      end
    end

    context 'somebody already paid for it' do
      before { create(:attendance, member_id: member.id, event_id: payment.id) }

      it 'rejects deletion' do
        expect(Event.where(id: payment.id).size).to eq(1)
        within(id: dom_id(payment)) { click_button('削除') }

        expect(current_path).to eq(payments_path)
        expect(page).to have_selector('.alert.alert-error', text: "関連する支払いがあるため、#{payment.event_name}を削除できませんでした。")
        expect(Event.where(id: payment.id).size).to eq(1)
      end
    end
  end
end
