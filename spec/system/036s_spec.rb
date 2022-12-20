require 'rails_helper'

RSpec.describe '036s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'
  let!(:year2) { create(:year) }

  RSpec.shared_examples '036 reject' do
    it 'does not show the link to years' do
      expect(page).to_not have_link('年次情報管理', href: years_path)
    end

    it 'rejects access' do
      visit(years_path)
      expect(current_path).to_not eq(years_path)
      expect(page).to have_selector('p.alert.alert-error', text: 'Access denied')
    end
  end

  context 'normal user' do
    include_context 'login'
    it_behaves_like '036 reject'
  end

  context 'lead' do
    include_context 'login as lead'
    it_behaves_like '036 reject'
  end

  context 'board' do
    include_context 'login as board'
    it_behaves_like '036 reject'
  end

  context 'admin' do
    include_context 'login as admin'

    it 'is possible to access year list' do
      expect(page).to have_link('年次情報管理', href: years_path)
      click_link('年次情報管理', href: years_path)
      expect(current_path).to eq(years_path)
    end

    it 'shows all years' do
      click_link('年次情報管理', href: years_path)
      expect(Year.all.size).to eq(2)
      [year, year2].each do |y|
        within(id: dom_id(y)) do
          expect(page).to have_text("#{y.graduate_year}回卒")
          expect(page).to have_text("#{y.anno_domini}年3月")
          expect(page).to have_text("#{y.japanese_calendar}年3月")
        end
      end
    end
  end
end
