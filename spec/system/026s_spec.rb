require 'rails_helper'

RSpec.describe '026s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  let!(:member1) { create(:member, year_id: member.year_id) }
  let!(:user1) { create(:user, member_id: member1.id) }
  let!(:member2) { create(:member) }
  let!(:user2) { create(:user, member_id: member2.id) }

  RSpec.shared_examples '026 mail list' do
    it 'shows the link to mail address' do
      expect(page).to have_link('メールアドレス一覧', href: exports_emails_path)
    end

    it 'is possible to access mail list page' do
      click_link('メールアドレス一覧', href: exports_emails_path)
      expect(current_path).to eq(exports_emails_path)
    end

    it 'shows list of all mails' do
      click_link('メールアドレス一覧', href: exports_emails_path)
      expect(page).to have_text("#{member1.family_name} #{member1.first_name}")
      expect(page).to have_text(user1.email)
      expect(page).to have_text("#{member2.family_name} #{member2.first_name}")
      expect(page).to have_text(user2.email)
    end
  end

  context 'board' do
    include_context 'login as board'

    it_behaves_like '026 mail list'
  end

  context 'admin' do
    include_context 'login as admin'

    it_behaves_like '026 mail list'
  end
end
