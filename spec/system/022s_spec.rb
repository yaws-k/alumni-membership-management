require 'rails_helper'

RSpec.describe '022s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  let!(:member1) { create(:member, :full_fields, year_id: member.year_id) }
  let!(:member2) { create(:member) }

  RSpec.shared_examples '022 board' do
    it 'shows all year members' do
      within(id: dom_id(member.year)) do
        within(id: dom_id(member)) do
          expect(page).to have_text(member.family_name)
          expect(page).to have_link('詳細', href: member_path(member))
        end

        within(id: dom_id(member1)) do
          expect(page).to have_text(member1.family_name)
          expect(page).to have_link('詳細', href: member_path(member1))
        end
      end

      within(id: dom_id(member2.year)) do
        within(id: dom_id(member2)) do
          expect(page).to have_text(member2.family_name)
          expect(page).to have_link('詳細', href: member_path(member2))
        end
      end
    end
  end

  context 'board' do
    before { member.update(roles: %w[board]) }
    include_context 'login'

    context 'root_path' do
      it 'redirects to root_path' do
        expect(current_path).to eq(root_path)
      end

      it_behaves_like '022 board'
    end

    context 'members_path' do
      it 'is available to access members_path' do
        visit members_path
        expect(current_path).to eq(members_path)
      end

      it_behaves_like '022 board'
    end
  end
end
