require 'rails_helper'

RSpec.describe '021s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  # Same year, annual fee paid
  let!(:member1) { create(:member, year_id: year.id) }
  let!(:attendance1) { create(:attendance, member_id: member1.id, event_id: payment.id, payment_date: Date.today) }

  # Different yaer, lead
  let!(:user2) { create(:user) }
  let!(:member2) { user2.member }
  let!(:dummy) { member2.update(roles: %w[lead]) }

  RSpec.shared_examples '021 members' do
    it 'shows the link' do
      expect(page).to have_link('年次別統計', href: statistics_members_path)
    end

    it 'accespts access' do
      click_link('年次別統計', href: statistics_members_path)
      expect(current_path).to eq(statistics_members_path)
    end

    it 'shows counts' do
      click_link('年次別統計', href: statistics_members_path)
      within(id: dom_id(year)) do
        expect(page).to have_text(year.graduate_year)
        expect(page).to have_text(2)
        expect(page).to have_text(1)
      end
    end

    it 'shows lead names and emails' do
      click_link('年次別統計', href: statistics_members_path)
      within(id: dom_id(member2.year)) do
        expect(page).to have_text(member2.year.graduate_year)
        expect(page).to have_text(1)
        expect(page).to have_text(0)
        expect(page).to have_text("#{member2.family_name} #{member2.first_name}")
        expect(page).to have_text(user2.email)
      end
    end
  end

  context 'normal user' do
    include_context 'login'

    it 'does not show the link' do
      expect(page).to_not have_link('年次別統計', href: statistics_members_path)
    end

    it 'rejects access' do
      visit statistics_members_path
      expect(current_path).to eq(member_path(member))
    end
  end

  context 'lead' do
    include_context 'login as lead'

    it_behaves_like '021 members'
  end

  context 'board' do
    include_context 'login as board'

    it_behaves_like '021 members'
  end

  context 'admin' do
    include_context 'login as admin'

    it_behaves_like '021 members'
  end
end
