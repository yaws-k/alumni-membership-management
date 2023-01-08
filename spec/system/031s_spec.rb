require 'rails_helper'

RSpec.describe '031s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  let!(:donation) { create(:event, :payment) }

  let!(:member1) { create(:member) }
  let!(:attendance1) { create(:attendance, member_id: member1.id, event_id: payment.id, payment_date: Date.new(2022, 10, 1), amount: 3000) }

  let!(:member2) { create(:member) }
  let!(:attendance2) { create(:attendance, member_id: member2.id, event_id: donation.id, payment_date: Date.new(2022, 11, 1), amount: 1000) }

  RSpec.shared_examples '031 rejects access' do
    it 'do not show the link' do
      expect(page).to_not have_link('入金一覧', href: statistics_incomes_path)
      expect(page).to_not have_link('年会費一覧', href: statistics_annual_fees_path)
      expect(page).to_not have_link('寄付金一覧', href: statistics_donations_path)
    end

    it 'rejects access' do
      visit statistics_incomes_path

      expect(current_path).to_not eq(statistics_incomes_path)
      expect(page).to have_selector('p.alert.alert-error', text: 'Access denied')
    end
  end

  RSpec.shared_examples '031 accepts access' do
    it 'shows links' do
      expect(page).to have_link('入金一覧', href: statistics_incomes_path)
      expect(page).to have_link('年会費一覧', href: statistics_annual_fees_path)
      expect(page).to have_link('寄付金一覧', href: statistics_donations_path)
    end

    it 'accepts access' do
      click_link('入金一覧', href: statistics_incomes_path)
      expect(current_path).to eq(statistics_incomes_path)
    end

    it 'shows all incomes' do
      click_link('入金一覧', href: statistics_incomes_path)

      expect(page).to have_selector('h2', text: '2022/09/01-2023/08/31')

      within(id: dom_id(attendance1)) do
        expect(page).to have_text(attendance1.payment_date)
        expect(page).to have_text('3,000')
        expect(page).to have_text(payment.event_name)
      end

      within(id: dom_id(attendance2)) do
        expect(page).to have_text(attendance2.payment_date)
        expect(page).to have_text('1,000')
        expect(page).to have_text(donation.event_name)
      end
    end

    it 'shows only annual_fees' do
      click_link('年会費一覧', href: statistics_annual_fees_path)

      expect(page).to have_selector('h2', text: payment.event_name)

      within(id: dom_id(attendance1)) do
        expect(page).to have_text(attendance1.payment_date)
        expect(page).to have_text('3,000')
        expect(page).to have_text(payment.event_name)
      end

      expect(page).to_not have_text(attendance2.payment_date)
      expect(page).to_not have_text('1,000')
      expect(page).to_not have_text(donation.event_name)
    end

    it 'shows only donations' do
      click_link('寄付金一覧', href: statistics_donations_path)

      expect(page).to have_selector('h2', text: '2022/09/01-2023/08/31')

      expect(page).to_not have_text(attendance1.payment_date)
      expect(page).to_not have_text('3,000')

      within(id: dom_id(attendance2)) do
        expect(page).to have_text(attendance2.payment_date)
        expect(page).to have_text('1,000')
        expect(page).to have_text(donation.event_name)
      end
    end
  end

  context 'normal user' do
    include_context 'login'

    it_behaves_like '031 rejects access'
  end

  context 'lead' do
    include_context 'login as lead'

    it_behaves_like '031 rejects access'
  end

  context 'board' do
    include_context 'login as board'

    it_behaves_like '031 accepts access'
  end

  context 'admin' do
    include_context 'login as admin'

    it_behaves_like '031 accepts access'
  end
end
