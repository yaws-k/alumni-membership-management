require 'rails_helper'

RSpec.describe '038s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  context 'admin' do
    include_context 'login as admin'
    before do
      click_link('年次情報管理', href: years_path)
    end

    it 'is possible to access edit screen' do
      expect(page).to have_link('編集', href: edit_year_path(year))
      click_link('編集', href: edit_year_path(year))
      expect(current_path).to eq(edit_year_path(year))
    end

    it 'shows edit fields' do
      click_link('編集', href: edit_year_path(year))
      expect(page).to have_field('year_graduate_year')
      expect(page).to have_field('year_anno_domini')
      expect(page).to have_field('year_japanese_calendar')
    end

    it 'is possible to update year' do
      click_link('編集', href: edit_year_path(year))
      fill_in('year_anno_domini', with: '123456')
      click_button('送信')

      expect(current_path).to eq(years_path)
      within(id: dom_id(year)) do
        expect(page).to have_text('123456年3月')
      end
    end
  end
end
