require 'rails_helper'

RSpec.describe '037s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  context 'admin' do
    include_context 'login as admin'
    before do
      click_link('年次情報管理', href: years_path)
      expect(page).to have_link('年次追加', href: new_year_path)
      click_link('年次追加', href: new_year_path)
    end

    it 'shows fields for new year' do
      expect(current_path).to eq(new_year_path)
      expect(page).to have_field('year_graduate_year')
      expect(page).to have_field('year_anno_domini')
      expect(page).to have_field('year_japanese_calendar')
    end

    it 'is possible to create new event' do
      fill_in('year_graduate_year', with: '高75')
      fill_in('year_anno_domini', with: '2023')
      fill_in('year_japanese_calendar', with: '令和5')
      click_button('送信')

      within(id: dom_id(Year.find_by(anno_domini: '2023'))) do
        expect(current_path).to eq(years_path)
        expect(page).to have_text('高75回卒')
        expect(page).to have_text('2023年3月')
        expect(page).to have_text('令和5年3月')
      end
    end
  end
end
