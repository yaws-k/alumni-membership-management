require 'rails_helper'

RSpec.describe '006s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'
  let!(:event) { create(:event, :full_fields) }
  let!(:attendance1) { create(:attendance, event_id: event.id, application: true) }
  let!(:attendance2) { create(:attendance, event_id: event.id, application: true) }
  let!(:attendance3) { create(:attendance, event_id: event.id, application: true) }
  let!(:attendance4) { create(:attendance, event_id: event.id, application: false) }

  let(:member1) { attendance1.member }
  let(:member2) { attendance2.member }
  let(:member3) { attendance3.member }
  let(:member4) { attendance4.member }

  RSpec.shared_examples '006 event detail' do
    before do
      visit members_path
      click_link('イベント一覧', href: events_path)
      click_link('詳細', href: event_path(event))
    end

    it 'is possible to see event details' do
      expect(page).to have_text(event.event_date)
      expect(page).to have_text(event.fee.to_fs(:delimited))
    end

    it 'is possible to see the number of applicants' do
      expect(page).to have_text('参加申込者数：3')
    end

    it 'is possible to see applicants' do
      Attendance.where(application: true).each do |attendance|
        member = attendance.member
        within(id: dom_id(member)) do
          expect(page).to have_text(member.year.graduate_year)
          expect(page).to have_text(member.family_name_phonetic)
          expect(page).to have_text(member.first_name_phonetic)
          expect(page).to have_text(member.family_name)
          expect(page).to have_text(member.first_name)

          if with_detail
            expect(page).to have_link('詳細', href: member_path(member))
          else
            expect(page).to_not have_link('詳細', href: member_path(member))
          end
        end
      end
    end

    it 'does not show applicants declared absence' do
      within(id: 'applicants') do
        expect(page).to_not have_text((member4.family_name))
        expect(page).to_not have_text((member4.first_name))
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
    include_context 'login'
    let(:with_detail) { false }

    it_behaves_like '006 event detail'
  end

  context 'lead' do
    include_context 'login as lead'
    let(:with_detail) { false }

    it_behaves_like '006 event detail'
  end

  context 'board' do
    include_context 'login as board'
    let(:with_detail) { true }

    it_behaves_like '006 event detail'
  end

  context 'admin' do
    include_context 'login as admin'
    let(:with_detail) { true }

    it_behaves_like '006 event detail'
  end
end
