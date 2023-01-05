require 'rails_helper'

RSpec.describe '029s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  let!(:payment) { create(:event, :annual_fee) }

  RSpec.shared_examples '029 no create' do
    it 'does not show payment history creation link' do
      expect(page).to_not have_link('履歴登録', href: new_payment_history_path(member_id: member.id))
    end
  end

  RSpec.shared_examples '029 create' do
    it 'shows payment_history create link' do
      expect(page).to have_link('履歴登録', href: new_payment_history_path(member_id: member.id))
    end

    it 'is possible to access payment_history create screen' do
      click_link('履歴登録', href: new_payment_history_path(member_id: member.id))
      expect(current_path).to eq(new_payment_history_path)
    end

    it 'is possible to create new history' do
      click_link('履歴登録', href: new_payment_history_path(member_id: member.id))
      select(payment.event_name, from: 'attendance_event_id')
      fill_in('attendance_payment_date', with: (Date.today - 1))
      fill_in('attendance_amount', with: 3000)
      fill_in('attendance_note', with: '備考欄')
      click_button('送信')
      attendance = Attendance.last

      expect(current_path).to eq(member_path(member))
      within(id: dom_id(payment)) do
        expect(page).to have_text(payment.event_name)
        expect(page).to have_text(payment.event_date)
        expect(page).to have_text(attendance.payment_date)
        expect(page).to have_text('3,000')
        expect(page).to have_text('備考欄')
      end
    end
  end

  context 'normal user' do
    include_context 'login'

    it_behaves_like '029 no create'
  end

  context 'lead' do
    include_context 'login as lead'
    before { click_link('詳細', href: member_path(member)) }

    it_behaves_like '029 no create'
  end

  context 'board' do
    include_context 'login as board'
    before { click_link('詳細', href: member_path(member)) }

    it_behaves_like '029 create'
  end

  context 'admin' do
    include_context 'login as admin'
    before { click_link('詳細', href: member_path(member)) }

    it_behaves_like '029 create'
  end
end
