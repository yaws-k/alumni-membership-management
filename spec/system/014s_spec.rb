require 'rails_helper'

RSpec.describe '014s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  let!(:member1) { create(:member, :full_fields, year_id: member.year_id) }
  let!(:member2) { create(:member) }
  let!(:payment) { create(:event, :payment, event_name: '年会費') }

  RSpec.shared_examples 'normal user' do
    it 'skips members_path' do
      expect(current_path).to eq(member_path(member))
    end
  end

  RSpec.shared_examples 'lead' do
    it 'shows same year members' do
      within(id: dom_id(member)) { expect(page).to have_text(member.family_name) }
      within(id: dom_id(member1)) { expect(page).to have_text(member1.family_name) }
      expect(page).to_not have_text(member2.family_name)
    end

    it 'shows names and links to their details' do
      within(id: dom_id(member)) do
        expect(page).to have_text(member.family_name)
        expect(page).to have_text(member.first_name)
        expect(page).to have_text(member.family_name_phonetic)
        expect(page).to have_text(member.first_name_phonetic)
        expect(page).to have_selector('td.text-success', text: member.communication)
        expect(page).to have_selector('td.text-warning', text: '未済')
        expect(page).to have_link('詳細', href: member_path(member))
      end

      within(id: dom_id(member1)) do
        expect(page).to have_text(member1.family_name)
        expect(page).to have_text(member1.first_name)
        expect(page).to have_text(member1.maiden_name)
        expect(page).to have_text(member1.family_name_phonetic)
        expect(page).to have_text(member1.first_name_phonetic)
        expect(page).to have_text(member1.maiden_name_phonetic)
        expect(page).to have_selector('td.text-success', text: member1.communication)
        expect(page).to have_selector('td.text-warning', text: '未済')
        expect(page).to have_link('詳細', href: member_path(member1))
      end
    end
  end

  context 'normal user' do
    include_context 'login'

    context 'root_path' do
      it_behaves_like 'normal user'
    end

    context 'members_path' do
      before { visit members_path }
      it_behaves_like 'normal user'
    end
  end

  context 'lead' do
    context 'root_path' do
      before { member.update(roles: %w[lead]) }
      include_context 'login'

      it 'redirects to root_path' do
        expect(current_path).to eq(root_path)
      end
      it_behaves_like 'lead'
    end

    context 'members_path' do
      before { member.update(roles: %w[lead]) }
      include_context 'login'

      it 'is available to access members_path' do
        visit members_path
        expect(current_path).to eq(members_path)
      end
      it_behaves_like 'lead'
    end
  end
end
