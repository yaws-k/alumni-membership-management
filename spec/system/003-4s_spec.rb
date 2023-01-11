require 'rails_helper'

RSpec.describe '003-4s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'
  let!(:event_open) { create(:event, event_date: (Date.today + 1)) }
  let!(:attendance1) { create(:attendance, member_id: member.id, event_id: event_open.id) }
  let!(:event_closed) { create(:event, event_date: Date.today) }
  let!(:attendance2) { create(:attendance, member_id: member.id, event_id: event_closed.id) }

  RSpec.shared_examples 'event application' do
    before { visit member_path(member) }

    context 'application buttons' do
      it 'shows application buttons for open events' do
        within(id: dom_id(attendance1)) do
          within(id: 'application') do
            expect(page).to have_button('出席')
            expect(page).to have_button('欠席')
            expect(page).to have_link('備考', href: edit_attendance_path(attendance1))
          end
        end
      end

      it 'does not show application buttons for open events' do
        within(id: dom_id(attendance2)) do
          within(id: 'application') do
            expect(page).to_not have_button('出席')
            expect(page).to_not have_button('欠席')
            expect(page).to_not have_link('備考', href: edit_attendance_path(attendance1))
          end
        end
      end
    end

    context 'application' do
      it 'is possible to apply as present' do
        within(id: dom_id(attendance1)) do
          within(id: 'presence') do
            expect(page).to have_text('未回答')
          end

          click_button('出席')

          within(id: 'presence') do
            expect(page).to have_text('出席')
          end
        end
      end

      it 'is possible to apply as NOT present' do
        within(id: dom_id(attendance1)) do
          within(id: 'presence') do
            expect(page).to have_text('未回答')
          end

          click_button('欠席')

          within(id: 'presence') do
            expect(page).to have_text('欠席')
          end
        end
      end
    end

    context 'add notes' do
      before do
        within(id: dom_id(attendance1)) { click_link('備考', href: edit_attendance_path(attendance1)) }
      end

      it 'is possible to add comments' do
        expect(current_path).to eq(edit_attendance_path(attendance1))
        choose('attendance_application_false')
        fill_in('attendance_note', with: 'Additional comments')
        click_button('送信')

        within(id: dom_id(attendance1)) do
          within(id: 'presence') do
            expect(page).to have_text('欠席')
          end
          expect(page).to have_text('Additional comments')
        end
      end
    end
  end

  context 'normal user' do
    include_context 'login'

    it_behaves_like 'event application'
  end

  context 'lead' do
    include_context 'login as lead'

    it_behaves_like 'event application'
  end

  context 'board' do
    include_context 'login as board'

    it_behaves_like 'event application'
  end

  context 'admin' do
    include_context 'login as admin'

    it_behaves_like 'event application'
  end
end
