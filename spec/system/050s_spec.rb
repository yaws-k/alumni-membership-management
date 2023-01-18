require 'rails_helper'

RSpec.describe '050s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  let!(:attendance1) { create(:attendance) }
  let!(:event1) { attendance1.event }

  context 'normal user' do
    include_context 'login'
    before { visit event_path(event1) }

    it 'does not show the link to download Excel' do
      expect(page).to_not have_link('参加者一覧をExcelでダウンロード', href: exports_event_participants_path(event_id: event1.id))
    end

    it 'rejects Excel download' do
      visit exports_event_participants_path(event_id: event1.id)
      expect(current_path).to eq(member_path(member))
    end
  end

  RSpec.shared_examples 'download excel' do
    before { visit event_path(event1) }

    it 'shows the link to download Excel' do
      expect(page).to have_link('参加者一覧をExcelでダウンロード', href: exports_event_participants_path(event_id: event1.id))
    end

    it 'accepts Excel download' do
      click_link('参加者一覧をExcelでダウンロード', href: exports_event_participants_path(event_id: event1.id))
      expect(current_path).to eq(exports_event_participants_path)
    end
  end

  context 'lead' do
    include_context 'login as lead'

    it_behaves_like 'download excel'
  end

  context 'board' do
    include_context 'login as board'

    it_behaves_like 'download excel'
  end

  context 'admin' do
    include_context 'login as admin'

    it_behaves_like 'download excel'
  end
end
