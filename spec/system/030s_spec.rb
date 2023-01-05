require 'rails_helper'

RSpec.describe '030s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  let!(:payment) { create(:event, :annual_fee) }
  let!(:attendance) { create(:attendance, :payment, member_id: member.id, event_id: payment.id) }

  RSpec.shared_examples '030 no edit' do
    it 'does not show payment history edit link' do
      within(id: dom_id(attendance)) do
        expect(page).to_not have_link('編集', href: edit_payment_history_path(attendance))
      end
    end

    it 'does not show payment history delete link' do
      within(id: dom_id(attendance)) do
        expect(page).to_not have_button('削除')
      end
    end
  end

  RSpec.shared_examples '030 edit' do
    it 'shows payment_history edit link' do
      expect(page).to have_link('編集', href: edit_payment_history_path(attendance))
    end

    it 'is possible to access payment_history edit screen' do
      click_link('編集', href: edit_payment_history_path(attendance))
      expect(current_path).to eq(edit_payment_history_path(attendance))
    end

    it 'is possible to edit a history' do
      click_link('編集', href: edit_payment_history_path(attendance))
      fill_in('attendance_amount', with: 5000)
      fill_in('attendance_note', with: '備考更新')
      click_button('送信')

      expect(current_path).to eq(member_path(member))
      within(id: dom_id(attendance)) do
        expect(page).to have_text(payment.event_name)
        expect(page).to have_text(payment.event_date)
        expect(page).to have_text(attendance.payment_date)
        expect(page).to have_text('5,000')
        expect(page).to have_text('備考更新')
      end
    end

    it 'shows payment_history delete link' do
      expect(page).to have_button('削除')
    end

    it 'is possible to delete payment_history' do
      within(id: dom_id(attendance)) { click_button('削除') }
      expect(current_path).to eq(member_path(member))
      expect(page).to have_text("#{payment.event_name}を削除しました。")
    end
  end

  context 'normal user' do
    include_context 'login'

    it_behaves_like '030 no edit'
  end

  context 'lead' do
    include_context 'login as lead'
    before { click_link('詳細', href: member_path(member)) }

    it_behaves_like '030 no edit'
  end

  context 'board' do
    include_context 'login as board'
    before { click_link('詳細', href: member_path(member)) }

    it_behaves_like '030 edit'
  end

  context 'admin' do
    include_context 'login as admin'
    before { click_link('詳細', href: member_path(member)) }

    it_behaves_like '030 edit'
  end
end
