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

    it 'does not show the link to add payment history' do
      visit "/members/#{member1.id}"
      expect(current_path).to eq(member_path(member1))
      expect(page).to_not have_link('履歴登録', href: new_payment_history_path(member_id: member1.id))
    end

    context 'existing histories' do
      let!(:payment) { create(:event, :annual_fee) }
      let!(:attendance) { create(:attendance, :payment, member_id: member1.id, event_id: payment.id) }

      it 'does not show links to edit payment history' do
        visit "/members/#{member1.id}"
        expect(current_path).to eq(member_path(member1))
        within(id: dom_id(attendance)) do
          expect(page).to_not have_link('編集', href: edit_payment_history_path(attendance))
        end
      end

      it 'does not show links to delete payment history' do
        visit "/members/#{member1.id}"
        expect(current_path).to eq(member_path(member1))
        within(id: dom_id(attendance)) do
          expect(page).to_not have_link('削除')
        end
      end
    end
  end
end
