require 'rails_helper'

RSpec.describe '039s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'
  let!(:year2) { create(:year) }

  context 'admin' do
    include_context 'login as admin'
    before do
      click_link('年次情報管理', href: years_path)
    end

    context 'nobody belongs' do
      it 'is possible to delete the year' do
        expect(Year.where(id: year2.id).size).to eq(1)
        within(id: dom_id(year2)) { click_button('削除') }

        expect(current_path).to eq(years_path)
        expect(page).to have_selector('.alert.alert-info', text: "#{year2.graduate_year}を削除しました。")
        expect(Event.where(id: year2.id).size).to eq(0)
      end
    end

    context 'member exists' do
      it 'rejects deletion' do
        expect(Year.where(id: year.id).size).to eq(1)
        within(id: dom_id(year)) { click_button('削除') }

        expect(current_path).to eq(years_path)
        expect(page).to have_selector('.alert.alert-error', text: '紐付くメンバーが存在する年次は消せません。')
        expect(Year.where(id: year.id).size).to eq(1)
      end
    end
  end
end
