require 'rails_helper'

RSpec.describe '006s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'
  include_context 'login'
  let!(:event) { create(:event, :full_fields) }
  let!(:attendance1) { create(:attendance, event_id: event.id, application: true) }
  let!(:attendance2) { create(:attendance, event_id: event.id, application: true) }
  let!(:attendance3) { create(:attendance, event_id: event.id, application: true) }

  let(:member1) { attendance1.member }
  let(:member2) { attendance2.member }
  let(:member3) { attendance3.member }

  RSpec.shared_examples 'event detail' do
    before do
      visit members_path
      click_link('イベント一覧', href: events_path)
      click_link('詳細', href: event_path(event))
    end

    it 'is possible to see event details' do
      expect(page).to have_text(event.event_date)
      expect(page).to have_text(event.fee.to_fs(:delimited))
    end

    it 'is possible to see participants' do
      Attendance.all.each do |attendance|
        member = attendance.member
        within(id: dom_id(member)) do
          expect(page).to have_text(member.year.graduate_year)
          expect(page).to have_text(member.family_name_phonetic)
          expect(page).to have_text(member.first_name_phonetic)
          expect(page).to have_text(member.family_name)
          expect(page).to have_text(member.first_name)
        end
      end
    end

    it 'sorts participants by guraduate year and phonetics' do
      member1.update(family_name_phonetic: 'あああ')
      member1.year.update(graduate_year: '高20', anno_domini: 2020)
      member2.update(family_name_phonetic: 'いいい', year_id: member3.year_id)
      member3.year.update(graduate_year: '高10', anno_domini: 2010)
      visit event_path(event)

      array = []
      [member3, member2, member1].each { |m| array << "id='#{dom_id(m)}'" }
      regexp = Regexp.new(array.join('.*'), Regexp::MULTILINE)
      expect(page.source).to match(regexp)
    end
  end

  context 'normal user' do
    it_behaves_like 'event detail'
  end

  context 'lead' do
    before { member.update(roles: %w[lead]) }
  end

  context 'board' do
    before { member.update(roles: %w[board]) }
  end

  context 'admin' do
    before { member.update(roles: %w[admin]) }
  end
end
