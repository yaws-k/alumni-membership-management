require 'rails_helper'

RSpec.describe '025s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  RSpec.shared_examples '025 delete info' do
    before { click_link('詳細', href: member_path(member1)) }

    context 'email' do
      it 'deletes email' do
        expect(User.where(id: user1.id).size).to eq(1)

        within(id: dom_id(user1)) { click_button('削除') }

        expect(current_path).to eq(member_path(member1))
        expect(page).to have_text("#{user1.email}を削除しました。")
        expect(User.where(id: user1.id).size).to eq(0)
      end
    end

    context 'delete address' do
      it 'deletes address' do
        expect(Address.where(id: address1.id).size).to eq(1)

        within(id: dom_id(address1)) { click_button('削除') }

        expect(current_path).to eq(member_path(member1))
        expect(page).to have_text("#{address1.postal_code}　#{address1.address1}　#{address1.address2}を削除しました。")
        expect(Address.where(id: address1.id).size).to eq(0)
      end
    end

    context 'delete member' do
      it 'deletes member' do
        expect(Member.where(id: member1.id).size).to eq(1)
        click_link('基本情報編集・削除', href: edit_member_path(member1))
        click_button('削除')
        expect(current_path).to eq(members_path)
        expect(page).to have_text("#{member1.first_name}を削除しました。")
        expect(Member.where(id: member1.id).size).to eq(0)
      end
    end
  end

  context 'same year member' do
    let!(:member1) { create(:member, :full_fields, year_id: member.year_id) }
    let!(:user1) { create(:user, member_id: member1.id) }
    let!(:address1) { create(:address, member_id: member1.id) }
    include_context 'login as board'

    it_behaves_like '025 delete info'
  end

  context 'different year member' do
    let!(:member1) { create(:member, :full_fields) }
    let!(:user1) { create(:user, member_id: member1.id) }
    let!(:address1) { create(:address, member_id: member1.id) }
    include_context 'login as board'

    it_behaves_like '025 delete info'
  end
end
