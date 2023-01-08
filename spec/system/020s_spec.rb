require 'rails_helper'

RSpec.describe '020s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  let!(:member1) { create(:member, year_id: member.year_id) }
  let!(:user1) { create(:user, member_id: member1.id) }
  let!(:member2) { create(:member) }
  let!(:user2) { create(:user, member_id: member2.id) }

  context 'normal user' do
    include_context 'login'

    it 'does not show the link to download Excel' do
      expect(page).to_not have_link('Excelダウンロード', href: exports_members_path)
    end

    it 'rejects Excel download' do
      visit exports_members_path
      expect(current_path).to eq(member_path(member))
    end
  end

  context 'lead' do
    include_context 'login as lead'

    it 'shows the link to download Excel' do
      expect(page).to have_link('Excelダウンロード', href: exports_members_path)
    end

    it 'accepts Excel download' do
      click_link('Excelダウンロード', href: exports_members_path)
      expect(current_path).to eq(exports_members_path)
    end
  end
end
