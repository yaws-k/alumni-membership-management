require 'rails_helper'

RSpec.describe '017s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  let!(:member1) { create(:member, :full_fields, year_id: member.year_id) }
  let!(:user1) { create(:user, member_id: member1.id) }
  let!(:member2) { create(:member) }
  let!(:user2) { create(:user, member_id: member2.id) }

  RSpec.shared_examples '017 normal user' do
    it 'rejects access to new member page' do
      visit new_member_path
      expect(current_path).to eq(member_path(member))
    end
  end

  RSpec.shared_examples '017 lead' do
    before { expect(current_path).to eq(root_path) }

    context 'the same year member' do
      it 'shows new member create link' do
        expect(page).to have_link('メンバー追加', href: new_member_path)
      end

      it 'is possible to create new member' do
        click_link('メンバー追加', href: new_member_path)
        expect(current_path).to eq(new_member_path)

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

      it 'offers the same graduate year as the only option' do
        click_link('メンバー追加', href: new_member_path)
        expect(current_path).to eq(new_member_path)

        expect(page).to have_select('member_year_id', with_options: [member1.year.graduate_year])
        expect(page).to_not have_select('member_year_id', with_options: [member2.year.graduate_year])
      end
    end

    context 'different year member' do
      it 'rejects access to different year member information' do
        visit "/members/#{member2.id}"
        expect(current_path).to eq(members_path)
      end
    end
  end

  context 'normal user' do
    include_context 'login'
    it_behaves_like '017 normal user'
  end

  context 'lead' do
    before { member.update(roles: %w[lead]) }
    include_context 'login'
    it_behaves_like '017 lead'
  end
end
