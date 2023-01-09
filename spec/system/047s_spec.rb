require 'rails_helper'

RSpec.describe '047s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'
  let!(:user1) { create(:user) }
  let!(:dummy) { user1.member.update(year_id: member.year_id) }
  let!(:member1) { user1.member }

  let!(:user2) { create(:user) }
  let!(:member2) { user2.member }

  RSpec.shared_examples '047 search results' do
    before do
      Member.all.each { |m| m.update(family_name: 'search') }
      User.update_all(email: 'search@example.com')
    end

    it 'shows search boxes' do
      expect(page).to have_field('name_search')
      expect(page).to have_field('email_search')
    end

    it 'accepts access to name search page' do
      click_button('氏名検索')
      expect(current_path).to eq(searches_name_path)
    end

    it 'returns name search results' do
      fill_in('name_search', with: 'sear')
      click_button('氏名検索')

      expect(page).to have_text('該当：3件')
      within(id: dom_id(member)) do
        expect(page).to have_text('search')
        expect(page).to have_text(member.first_name)
      end

      within(id: dom_id(member1)) do
        expect(page).to have_text('search')
        expect(page).to have_text(member1.first_name)
      end

      within(id: dom_id(member2)) do
        expect(page).to have_text('search')
        expect(page).to have_text(member2.first_name)
      end
    end

    it 'accepts access to email search page' do
      click_button('メール検索')
      expect(current_path).to eq(searches_email_path)
    end

    it 'returns email search results' do
      fill_in('email_search', with: 'search@example')
      click_button('メール検索')

      expect(page).to have_text('該当：3件')
      within(id: dom_id(member)) do
        expect(page).to have_text('search')
        expect(page).to have_text(member.first_name)
      end

      within(id: dom_id(member1)) do
        expect(page).to have_text('search')
        expect(page).to have_text(member1.first_name)
      end

      within(id: dom_id(member2)) do
        expect(page).to have_text('search')
        expect(page).to have_text(member2.first_name)
      end
    end
  end

  context 'normal user' do
    include_context 'login'

    it 'rejects access to name search page' do
      visit searches_name_path(name_search: 'dummy', commit: '氏名検索')
      expect(current_path).to eq(member_path(member))
    end

    it 'rejects access to email search page' do
      visit searches_name_path(email_search: 'dummy', commit: 'メール検索')
      expect(current_path).to eq(member_path(member))
    end
  end

  context 'lead' do
    include_context 'login as lead'

    it 'shows search boxes' do
      expect(page).to have_field('name_search')
      expect(page).to have_field('email_search')
    end

    it 'accepts access to name search page' do
      click_button('氏名検索')
      expect(current_path).to eq(searches_name_path)
    end

    it 'returns name search results' do
      fill_in('name_search', with: member1.family_name)
      click_button('氏名検索')

      expect(page).to have_text('該当：1件')
      within(id: dom_id(member1)) do
        expect(page).to have_text(member1.family_name)
        expect(page).to have_text(member1.first_name)
      end
      expect(page).to_not have_text(member2.family_name)
    end

    it 'accepts access to email search page' do
      click_button('メール検索')
      expect(current_path).to eq(searches_email_path)
    end

    it 'returns email search results' do
      fill_in('email_search', with: user1.email)
      click_button('メール検索')

      expect(page).to have_text('該当：1件')
      within(id: dom_id(member1)) do
        expect(page).to have_text(member1.family_name)
        expect(page).to have_text(member1.first_name)
      end
      expect(page).to_not have_text(member2.family_name)
    end
  end

  context 'board' do
    include_context 'login as board'

    it_behaves_like '047 search results'
  end

  context 'admin' do
    include_context 'login as admin'

    it_behaves_like '047 search results'
  end
end
