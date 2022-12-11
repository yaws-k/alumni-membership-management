require 'rails_helper'

RSpec.describe '002s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  RSpec.shared_examples '002 check contents' do
    context 'basic data' do
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

      it 'shows other basic data' do
        member.update(occupation: 'work or university')
        visit member_path(member)

        within(id: 'basicData') do
          expect(page).to have_text(member.communication)
          expect(page).to have_text('work or university')
        end
      end
    end

    context 'mail address' do
      it 'shows mail address' do
        visit member_path(member)

        within(id: 'mailAddress') do
          expect(page).to have_text('有効')
          expect(page).to have_text(user.email)
          expect(page).to have_text('編集')
          expect(page).to have_text('削除')
        end
      end
    end

    context 'postal address' do
      it 'shows postal address' do
        address = create(:address, :full_fields, member_id: member.id)
        visit member_path(member)

        within(id: 'postalAddress') do
          expect(page).to have_text('不達')
          expect(page).to have_text(address.postal_code)
          expect(page).to have_text(address.address1)
          expect(page).to have_text(address.address2)
          expect(page).to have_text('編集')
          expect(page).to have_text('削除')
        end
      end
    end

    context 'payment' do
      it 'shows payment history' do
        payment = create(:event, :payment)
        attendance = create(:attendance, :full_fields, member_id: member.id, event_id: payment.id, payment_date: Date.today - 10)
        visit member_path(member)

        within(id: 'payment') do
          expect(page).to have_text(payment.event_name)
          expect(page).to have_text(payment.event_date)
          expect(page).to have_text(attendance.payment_date)
          expect(page).to have_text(payment.fee.to_fs(:delimited))
          expect(page).to have_text(attendance.note)
        end
      end
    end

    context 'event' do
      it 'shows event application' do
        attendance1 = create(:attendance, member_id: member.id)
        attendance2 = create(:attendance, member_id: member.id, application: true, payment_date: Date.today - 10)
        attendance3 = create(:attendance, member_id: member.id, application: false)
        visit member_path(member)

        within(id: 'event') do
          [attendance1, attendance2, attendance3].each do |attendance|
            within(id: dom_id(attendance)) do
              expect(page).to have_text(attendance.event.event_name)
              expect(page).to have_text(attendance.event.event_date)
              expect(page).to have_text(attendance.event.fee.to_fs(:delimited))

              if attendance.event.event_date > Date.today
                expect(page).to have_button('出席')
                expect(page).to have_button('欠席')
                expect(page).to have_link('備考', href: edit_attendance_path(attendance))
              else
                expect(page).to_not have_button('出席')
                expect(page).to_not have_button('欠席')
                expect(page).to_not have_link('備考', href: edit_attendance_path(attendance))
              end
            end
          end
          within(id: dom_id(attendance1)) { expect(page).to have_text('未回答') }
          within(id: dom_id(attendance2)) do
            expect(page).to have_text(attendance2.payment_date)
            expect(page).to have_text('出席')
          end
          within(id: dom_id(attendance3)) { expect(page).to have_text('欠席') }
        end
      end
    end
  end

  context 'normal user' do
    include_context 'login'

    it_behaves_like '002 check contents'

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
    include_context 'login as lead'

    it_behaves_like '002 check contents'

    it 'shows roles' do
      visit member_path(member)
      within(id: 'basicData') do
        expect(page).to have_text('世話役')
      end
    end
  end

  context 'board' do
    include_context 'login as board'

    it_behaves_like '002 check contents'

    it 'shows roles' do
      visit member_path(member)
      within(id: 'basicData') do
        expect(page).to have_text('幹事')
      end
    end
  end

  context 'admin' do
    include_context 'login as admin'

    it_behaves_like '002 check contents'

    it 'shows roles' do
      visit member_path(member)
      within(id: 'basicData') do
        expect(page).to have_text('システム管理者')
      end
    end
  end
end
