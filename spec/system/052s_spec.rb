require 'rails_helper'

RSpec.describe '052s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'
  let!(:address) { create(:address, member_id: member.id) }
  let!(:attendance) { create(:attendance, event_id: payment.id, member_id: member.id) }

  RSpec.shared_examples '052 exports/all_data reject' do
    it 'does not show the link to download DB data' do
      expect(page).to_not have_link('DBデータエクスポート', href: exports_all_data_path)
    end

    it 'rejects DB data download' do
      visit exports_all_data_path
      expect(current_path).to eq(destination)
    end
  end

  context 'normal user' do
    include_context 'login'
    let(:destination) { member_path(member) }

    it_behaves_like '052 exports/all_data reject'
  end

  context 'lead' do
    include_context 'login as lead'
    let(:destination) { members_path }

    it_behaves_like '052 exports/all_data reject'
  end

  context 'board' do
    include_context 'login as board'
    let(:destination) { members_path }

    it_behaves_like '052 exports/all_data reject'
  end

  context 'admin' do
    include_context 'login as admin'
    it 'shows the link to download DB data' do
      expect(page).to have_link('DBデータエクスポート', href: exports_all_data_path)
    end

    it 'rejects DB data download' do
      click_link('DBデータエクスポート', href: exports_all_data_path)
      expect(current_path).to eq(exports_all_data_path)
    end
  end
end
