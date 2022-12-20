require 'rails_helper'

RSpec.describe '032s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  let!(:payment) { create(:event, :full_fields, payment_only: true, event_date: 10.days.after(Date.today)) }
  let!(:annual_fee) { create(:event, :annual_fee, event_date: 20.days.after(Date.today)) }

  RSpec.shared_examples '032 access denied' do
    it 'do not show the link' do
      expect(page).to_not have_link('支払い一覧', href: payments_path)
    end

    it 'rejects access to payments page' do
      visit payments_path

      expect(current_path).to_not eq(payments_path)
      expect(page).to have_selector('p.alert.alert-error', text: 'Access denied')
    end
  end

  RSpec.shared_examples '032 shows payments' do
    it 'shows the link' do
      expect(page).to have_link('支払い一覧', href: payments_path)
    end

    it 'shows payment events' do
      click_link('支払い一覧', href: payments_path)

      within(id: dom_id(payment)) do
        expect(page).to have_text(payment.event_name)
        expect(page).to_not have_text('✔')
        expect(page).to have_text(payment.event_date)
        expect(page).to have_text(payment.fee.to_fs(:delimited))
        expect(page).to have_text(payment.note)
        expect(page).to have_link('詳細', href: payment_path(payment))
        expect(page).to have_link('編集', href: edit_payment_path(payment))
        expect(page).to have_button('削除')
      end

      within(id: dom_id(annual_fee)) do
        expect(page).to have_text(annual_fee.event_name)
        expect(page).to have_text('✔')
        expect(page).to have_text(annual_fee.event_date)
        expect(page).to have_text(annual_fee.fee.to_fs(:delimited))
        expect(page).to have_link('詳細', href: payment_path(annual_fee))
        expect(page).to have_link('編集', href: edit_payment_path(annual_fee))
        expect(page).to have_button('削除')
      end
    end

    it 'sorts payment events by event date' do
      click_link('支払い一覧', href: payments_path)

      array = []
      [annual_fee, payment].each { |e| array << "id='#{dom_id(e)}'" }
      regexp = Regexp.new(array.join('.*'), Regexp::MULTILINE)
      expect(page.source).to match(regexp)
    end
  end

  context 'normal user' do
    include_context 'login'

    it_behaves_like '032 access denied'
  end

  context 'lead' do
    include_context 'login as lead'

    it_behaves_like '032 access denied'
  end

  context 'board' do
    include_context 'login as board'

    it_behaves_like '032 shows payments'
  end
end
