require 'rails_helper'

RSpec.describe '002s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'
  include_context 'login'

  RSpec.shared_examples 'check contents' do
    it 'shows graduate year' do
      visit member_path(member)
      within(id: 'basicData') do
        expect(page).to have_text("#{year.graduate_year}回卒（#{year.anno_domini}年／#{year.japanese_calendar}年3月卒）")
      end
    end

    context 'without maiden name' do
      it 'shows names' do
        visit member_path(member)
        within(id: 'basicData') do
          expect(page).to have_text(member.family_name_phonetic)
          expect(page).to have_text(member.first_name_phonetic)
          expect(page).to have_text(member.family_name)
          expect(page).to have_text(member.first_name)
        end
      end
    end

    context 'with maiden name' do
      it 'shows names' do
        member.update(maiden_name: '旧姓', maiden_name_phonetic: 'きゅうせい')
        visit member_path(member)
        within(id: 'basicData') do
          expect(page).to have_text(member.family_name_phonetic)
          expect(page).to have_text("（#{member.maiden_name_phonetic}）")
          expect(page).to have_text(member.first_name_phonetic)
          expect(page).to have_text(member.family_name)
          expect(page).to have_text("（#{member.maiden_name}）")
          expect(page).to have_text(member.first_name)
        end
      end
    end

    it 'shows other data' do
      member.update(occupation: 'work or university')
      visit member_path(member)
      within(id: 'basicData') do
        expect(page).to have_text(member.communication)
        expect(page).to have_text('work or university')
      end
    end
  end

  context 'normal user' do
    it_behaves_like 'check contents'
    it 'shows roles' do
      visit member_path(member)
      within(id: 'basicData') do
        expect(page).to_not have_text('世話役')
        expect(page).to_not have_text('幹事')
        expect(page).to_not have_text('システム管理者')
      end
    end
  end

  context 'lead' do
    before { member.update(roles: %w[lead]) }

    it_behaves_like 'check contents'
    it 'shows roles' do
      visit member_path(member)
      within(id: 'basicData') do
        expect(page).to have_text('世話役')
      end
    end
  end

  context 'board' do
    before { member.update(roles: %w[board]) }

    it_behaves_like 'check contents'
    it 'shows roles' do
      visit member_path(member)
      within(id: 'basicData') do
        expect(page).to have_text('幹事')
      end
    end
  end

  context 'admin' do
    before { member.update(roles: %w[admin]) }

    it_behaves_like 'check contents'
    it 'shows roles' do
      visit member_path(member)
      within(id: 'basicData') do
        expect(page).to have_text('システム管理者')
      end
    end
  end
end
