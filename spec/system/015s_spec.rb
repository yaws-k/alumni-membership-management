require 'rails_helper'

RSpec.describe '015s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  let!(:member1) { create(:member, :full_fields, year_id: member.year_id) }
  let!(:member2) { create(:member) }

  context 'normal user' do
    include_context 'login'

    it 'rejects access to the same year member details' do
      visit "/members/#{member1.id}"
      expect(current_path).to eq(member_path(member))
    end

    it 'rejects access to other year member details' do
      visit "/members/#{member2.id}"
      expect(current_path).to eq(member_path(member))
    end
  end

  context 'lead' do
    include_context 'login as lead'

    it 'accepts access to the same year member details' do
      expect(current_path).to eq(root_path)
      click_link('詳細', href: member_path(member1))
      expect(current_path).to eq(member_path(member1))
    end

    it 'does not show the link to other year members' do
      expect(current_path).to eq(root_path)
      expect(page).to_not have_link('詳細', href: member_path(member2))
    end

    it 'rejects access to other year memeber details' do
      visit "/members/#{member2.id}"
      expect(current_path).to eq(members_path)
    end

    it 'does not show the link to add payment history'

    it 'does not show links to edit and delete for payment history'
  end
end
