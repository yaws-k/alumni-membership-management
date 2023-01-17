require 'rails_helper'

RSpec.describe '049s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  let!(:attendance1) { create(:attendance, application: true) }
  let!(:member1) { attendance1.member }
  let!(:dummy) { member1.update(year_id: member.year_id) }
  let!(:event1) { attendance1.event }

  RSpec.shared_examples 'no edit button' do
    context 'future date' do
      before { event1.update(event_date: (Date.today + 1)) }

      it_behaves_like 'no edit button on event page'
      it_behaves_like 'no edit button on member page'
    end

    context 'past date' do
      before { event1.update(event_date: (Date.today - 1)) }

      it_behaves_like 'no edit button on event page'
      it_behaves_like 'no edit button on member page'
    end
  end

  RSpec.shared_examples 'no edit button on event page' do
    before { visit event_path(event1) }

    it 'does not show actual presence edit column' do
      within(id: dom_id(member1)) do
        expect(page).to_not have_link('編集', href: edit_attendance_path(attendance1, return_path: current_path))
      end
    end
  end

  RSpec.shared_examples 'no edit button on member page' do
    before { visit member_path(member1) }

    it 'does not show actual presence edit column' do
      within(id: dom_id(attendance1)) do
        expect(page).to_not have_link('編集', href: edit_attendance_path(attendance1))
      end
    end
  end

  RSpec.shared_examples 'with edit button' do
    context 'future date' do
      before { event1.update(event_date: (Date.today + 1)) }

      it_behaves_like 'no edit button on event page'
      it_behaves_like 'no edit button on member page'
    end

    context 'past date' do
      before { event1.update(event_date: (Date.today - 1)) }

      it_behaves_like 'with edit button on event page'
      it_behaves_like 'with edit button on member page'
    end
  end

  RSpec.shared_examples 'with edit button on event page' do
    before { visit event_path(event1) }

    it 'shows actual presence edit column' do
      within(id: dom_id(member1)) do
        expect(page).to have_link('編集', href: edit_attendance_path(attendance1, return_path: current_path))
      end
    end
  end

  RSpec.shared_examples 'with edit button on member page' do
    before { visit member_path(member1) }

    it 'shows actual presence edit column' do
      within(id: dom_id(attendance1)) do
        expect(page).to have_link('編集', href: edit_attendance_path(attendance1))
      end
    end
  end

  RSpec.shared_examples 'possible to update presence' do
    before { event1.update(event_date: (Date.today - 1)) }

    context 'event page' do
      before do
        visit event_path(event1)
        click_link('編集', href: edit_attendance_path(attendance1, return_path: current_path))
      end

      it 'shows go back link' do
        expect(page).to have_link('戻る', href: event_path(event1))
      end

      it 'shows update fields' do
        expect(page).to have_field('attendance_application_true')
        expect(page).to have_field('attendance_application_false')
        expect(page).to have_field('attendance_presence_true')
        expect(page).to have_field('attendance_presence_false')
        expect(page).to have_field('attendance_note')
      end

      it 'updates presence' do
        choose('attendance_presence_true')
        click_button('送信')

        expect(current_path).to eq(event_path(event1))
        within(id: dom_id(member1)) do
          within(id: 'presence') do
            expect(page).to have_text('出席')
          end
        end
      end
    end

    context 'member page' do
      before do
        visit member_path(member1)
        click_link('編集', href: edit_attendance_path(attendance1))
      end

      it 'shows go back link' do
        expect(page).to have_link('戻る', href: member_path(member1, anchor: dom_id(attendance1)))
      end

      it 'shows update fields' do
        expect(page).to have_field('attendance_application_true')
        expect(page).to have_field('attendance_application_false')
        expect(page).to have_field('attendance_presence_true')
        expect(page).to have_field('attendance_presence_false')
        expect(page).to have_field('attendance_note')
      end

      it 'updates presence' do
        choose('attendance_presence_true')
        click_button('送信')

        expect(current_path).to eq(member_path(member1))
        within(id: dom_id(attendance1)) do
          within(id: 'presence') do
            expect(page).to have_text('出席')
          end
        end
      end
    end
  end

  context 'normal user' do
    include_context 'login'

    context 'future date' do
      before { event1.update(event_date: (Date.today + 1)) }

      it_behaves_like 'no edit button on event page'
    end

    context 'past date' do
      before { event1.update(event_date: (Date.today - 1)) }

      it_behaves_like 'no edit button on event page'
    end
  end

  context 'lead' do
    include_context 'login as lead'

    it_behaves_like 'no edit button'
  end

  context 'board' do
    include_context 'login as board'

    it_behaves_like 'with edit button'
    it_behaves_like 'possible to update presence'
  end
end
