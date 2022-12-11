require 'rails_helper'

RSpec.describe '024s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'
  include_context 'login as board'

  let!(:year2) { create(:year) }

  it 'is possible to access member creation page' do
    expect(page).to have_link('メンバー追加', href: new_member_path)
  end

  it 'is possible to choose any existing years' do
    click_link('メンバー追加', href: new_member_path)
    expect(page).to have_select('member_year_id', options: [member.year.graduate_year, year2.graduate_year])
  end

  it 'is possible to add new member' do
    click_link('メンバー追加', href: new_member_path)

    fill_in('member_family_name_phonetic', with: 'しんき')
    fill_in('member_first_name_phonetic', with: 'とうろく')
    fill_in('member_family_name', with: '新規')
    fill_in('member_first_name', with: '登録')
    click_button('送信')

    expect(current_path).to eq(member_path(Member.last))
    within(id: 'basicData') do
      expect(page).to have_text('しんき')
      expect(page).to have_text('とうろく')
      expect(page).to have_text('新規')
      expect(page).to have_text('登録')
    end
  end
end
