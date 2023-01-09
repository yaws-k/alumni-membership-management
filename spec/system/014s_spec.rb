require 'rails_helper'

RSpec.describe '014s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  let!(:member1) { create(:member, :full_fields, year_id: member.year_id) }
  let!(:member2) { create(:member) }

  context 'normal user' do
    include_context 'login'

    it 'skips members_path' do
      expect(current_path).to eq(member_path(member))
    end

    it 'redirects from members_path' do
      visit members_path
      expect(current_path).to eq(member_path(member))
    end
  end

  context 'lead' do
    include_context 'login as lead'

    it 'redirects to root_path' do
      expect(current_path).to eq(root_path)
    end

    it 'is possible to access members_path' do
      visit members_path
      expect(current_path).to eq(members_path)
    end

    it 'shows same year members' do
      expect(page).to have_text("#{member1.year.graduate_year}（#{member1.year.anno_domini}年／#{member1.year.japanese_calendar}年3月卒）　2人")
      within(id: dom_id(member)) { expect(page).to have_text(member.family_name) }
      within(id: dom_id(member1)) { expect(page).to have_text(member1.family_name) }
    end

    it 'shows names and links to their details' do
      within(id: dom_id(member)) do
        expect(page).to have_text(member.family_name)
        expect(page).to have_text(member.first_name)
        expect(page).to have_text(member.family_name_phonetic)
        expect(page).to have_text(member.first_name_phonetic)
        expect(page).to have_selector('td.text-success', text: member.communication)
        expect(page).to have_selector('td.text-warning', text: '未済')
        expect(page).to have_link('詳細', href: member_path(member))
      end

      within(id: dom_id(member1)) do
        expect(page).to have_text(member1.family_name)
        expect(page).to have_text(member1.first_name)
        expect(page).to have_text(member1.maiden_name)
        expect(page).to have_text(member1.family_name_phonetic)
        expect(page).to have_text(member1.first_name_phonetic)
        expect(page).to have_text(member1.maiden_name_phonetic)
        expect(page).to have_selector('td.text-success', text: member1.communication)
        expect(page).to have_selector('td.text-warning', text: '未済')
        expect(page).to have_link('詳細', href: member_path(member1))
      end
    end
  end
end
