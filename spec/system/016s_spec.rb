require 'rails_helper'

RSpec.describe '016s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  let!(:member1) { create(:member, :full_fields, year_id: member.year_id) }
  let!(:user1) { create(:user, member_id: member1.id) }
  let!(:address1) { create(:address, member_id: member1.id) }

  let!(:member2) { create(:member) }
  let!(:user2) { create(:user, member_id: member2.id) }
  let!(:address2) { create(:address, member_id: member2.id) }

  let!(:event) { create(:event, event_date: (Date.today + 1))}

  context 'normal user' do
    include_context 'login'

    it 'rejects access to the same member information' do
      visit "/members/#{member1.id}"
      expect(current_path).to eq(member_path(member))
    end

    it 'rejects access to the same member edit' do
      visit "/members/#{member1.id}/edit"
      expect(current_path).to eq(member_path(member))
    end

    it 'rejects access to other year member edit' do
      visit "/members/#{member2.id}/edit"
      expect(current_path).to eq(member_path(member))
    end
  end

  context 'lead' do
    include_context 'login as lead'

    context 'the same year member' do
      before { click_link('詳細', href: member_path(member1)) }

      context 'basic member information' do
        it 'is possible to edit member information' do
          click_link('基本情報編集・削除', href: edit_member_path(member1))
          fill_in('member_family_name_phonetic', with: 'Edited')
          click_button('送信')

          expect(current_path).to eq(member_path(member1))
          within(id: 'basicData') { expect(page).to have_text('Edited') }
        end

        it 'hides role checkboxes' do
          click_link('基本情報編集・削除', href: edit_member_path(member1))

          expect(page).to_not have_selector('.table', id: 'roles')
        end

        it 'does not affect roles' do
          member1.update(roles: %w[board])
          click_link('基本情報編集・削除', href: edit_member_path(member1))
          fill_in('member_family_name_phonetic', with: 'Edited family name')
          click_button('送信')

          expect(Member.find(member1.id).roles).to eq(%w[board])
        end
      end

      context 'email' do
        it 'is possible to create new email' do
          click_link('メールアドレス登録', href: new_member_user_path(member1))
          fill_in('user_email', with: 'new_mail@example.com')
          click_button('送信')

          expect(current_path).to eq(member_path(member1))
          within(id: 'mailAddress') { expect(page).to have_text('new_mail@example.com') }
        end

        it 'is possible to edit email' do
          click_link('編集', href: edit_member_user_path(member1, user1))
          fill_in('user_email', with: 'edit_mail@example.com')
          click_button('送信')

          expect(current_path).to eq(member_path(member1))
          within(id: dom_id(user1)) { expect(page).to have_text('edit_mail@example.com') }
        end
      end

      context 'address' do
        it 'is possible to create new address' do
          click_link('住所登録', href: new_member_address_path(member1))
          fill_in('address_postal_code', with: '100-0006')
          fill_in('address_address1', with: '東京都千代田区有楽町2-9-17')
          fill_in('address_address2', with: '有楽町駅')
          check('address_unreachable')
          click_button('送信')

          expect(current_path).to eq(member_path(member1))
          within(id: 'postalAddress') do
            expect(page).to have_text('不達')
            expect(page).to have_text('100-0006')
            expect(page).to have_text('東京都千代田区有楽町2-9-17')
            expect(page).to have_text('有楽町駅')
          end
        end

        it 'is possible to edit address' do
          click_link('編集', href: edit_member_address_path(member1, address1))
          fill_in('address_postal_code', with: '100-0006')
          check('address_unreachable')
          click_button('送信')

          expect(current_path).to eq(member_path(member1))
          within(id: 'postalAddress') do
            within(id: dom_id(address1)) do
              expect(page).to have_text('不達')
              expect(page).to have_text('100-0006')
            end
          end
        end
      end

      context 'events' do
        let(:attendance1) { Attendance.find_by(member_id: member1.id, event_id: event.id) }

        it 'is possible to update event application' do
          within(id: dom_id(attendance1)) do
            within(id: 'schedule') do
              expect(page).to have_text('未入力')
            end

            click_button('出席')

            within(id: 'schedule') do
              expect(page).to have_text('出席')
            end
          end
        end

        it 'is possible to add attendance notes' do
          within(id: dom_id(attendance1)) do
            click_link('備考', href: edit_attendance_path(attendance1))
          end
          expect(current_path).to eq(edit_attendance_path(attendance1))

          choose('欠席')
          fill_in('attendance_note', with: 'Additional comments')
          click_button('送信')

          expect(current_path).to eq(member_path(member1))
          within(id: dom_id(attendance1)) do
            within(id: 'schedule') do
              expect(page).to have_text('欠席')
            end
            expect(page).to have_text('Additional comments')
          end
        end
      end
    end

    context 'different year member' do
      it 'rejects access to different year member information' do
        visit "/members/#{member2.id}"
        expect(current_path).to eq(members_path)
      end
    end
  end
end
