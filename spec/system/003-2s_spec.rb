require 'rails_helper'

RSpec.describe '003-2s', type: :system do
  before do
    driven_by(:rack_test)
    user.update(password: 'currentPassword', password_confirmation: 'currentPassword')
  end

  include_context 'base user'
  include_context 'login'

  RSpec.shared_examples '003-2 new user' do
    before do
      visit member_path(member)
      click_link('メールアドレス登録', href: new_member_user_path(member))
    end

    context 'check fields' do
      it 'shows 003-2 new user link' do
        visit member_path(member)
        expect(page).to have_link('メールアドレス登録', href: new_member_user_path(member))
      end

      it 'shows input fields' do
        expect(page).to have_field('user_email')
        expect(page).to have_field('user_password')
        expect(page).to have_field('user_password_confirmation')
        expect(page).to have_field('user_unreachable')
      end
    end

    context 'create' do
      before do
        fill_in('user_email', with: 'new_mail@example.com')
        fill_in('user_password', with: 'difficultPassword')
        fill_in('user_password_confirmation', with: 'difficultPassword')
        click_button('送信')
      end

      it 'redirects to member detail page' do
        expect(current_path).to eq(member_path(member))
      end

      it 'shows created email' do
        within(id: 'mailAddress') do
          expect(page).to have_text('new_mail@example.com')
        end
      end
    end

    context 'registration' do
      it 'stores password for login' do
        fill_in('user_email', with: 'new_mail@example.com')
        fill_in('user_password', with: 'difficultPassword')
        fill_in('user_password_confirmation', with: 'difficultPassword')
        click_button('送信')
        click_button('Logout')

        visit new_user_session_path
        fill_in 'user_email', with: 'new_mail@example.com'
        fill_in 'user_password', with: 'difficultPassword'
        click_button 'ログイン'

        expect(page).to have_text('Signed in successfully.')
      end
    end
  end

  RSpec.shared_examples '003-2 edit user' do
    context 'check fields' do
      before do
        visit member_path(member)
        click_link('編集', href: edit_member_user_path(member, user))
      end

      it 'shows edit user link' do
        visit member_path(member)
        expect(page).to have_link('編集', href: edit_member_user_path(member, user))
      end

      it 'shows input fields' do
        expect(page).to have_field('user_email')
        expect(page).to have_field('user_password')
        expect(page).to have_field('user_password_confirmation')
        expect(page).to have_field('user_unreachable')
      end
    end

    context 'update' do
      context 'current email' do
        before do
          visit member_path(member)
          click_link('編集', href: edit_member_user_path(member, user))
        end

        context 'email change only' do
          before do
            fill_in('user_email', with: 'edit_mail@example.com')
            click_button('送信')
          end

          it 'redirects to member detail page' do
            expect(current_path).to eq(member_path(member))
            within(id: 'mailAddress') do
              expect(page).to have_text('edit_mail@example.com')
            end
          end

          it 'preserves old password' do
            click_button('Logout')

            visit new_user_session_path
            fill_in 'user_email', with: 'edit_mail@example.com'
            fill_in 'user_password', with: 'currentPassword'
            click_button 'ログイン'

            expect(page).to have_text('Signed in successfully.')
          end
        end

        context 'password change' do
          before do
            fill_in('user_email', with: 'edit_mail@example.com')
            fill_in('user_password', with: 'editPassword')
            fill_in('user_password_confirmation', with: 'editPassword')
            click_button('送信')
          end

          it 'redirects to login page' do
            expect(current_path).to eq(new_user_session_path)
          end

          it 'updates password' do
            visit new_user_session_path
            fill_in 'user_email', with: 'edit_mail@example.com'
            fill_in 'user_password', with: 'editPassword'
            click_button 'ログイン'

            expect(page).to have_text('Signed in successfully.')
          end
        end
      end

      context 'another email' do
        let!(:user2) { create(:user, member_id: member.id) }

        before do
          visit member_path(member)
          within(id: dom_id(user2)) { click_link('編集', href: edit_member_user_path(member, user2)) }
          fill_in('user_email', with: 'edit_mail@example.com')
          fill_in('user_password', with: 'editPassword')
          fill_in('user_password_confirmation', with: 'editPassword')
          check('user_unreachable')
          click_button('送信')
        end

        it 'redirects to member detail page' do
          expect(current_path).to eq(member_path(member))
          within(id: 'mailAddress') do
            within(id: dom_id(user2)) do
              expect(page).to have_text('不達')
              expect(page).to have_text('edit_mail@example.com')
            end
          end
        end

        it 'updates password' do
          click_button('Logout')

          visit new_user_session_path
          fill_in 'user_email', with: 'edit_mail@example.com'
          fill_in 'user_password', with: 'editPassword'
          click_button 'ログイン'

          expect(page).to have_text('Signed in successfully.')
        end
      end
    end
  end

  context 'normal user' do
    it_behaves_like '003-2 new user'
    it_behaves_like '003-2 edit user'
  end

  context 'lead' do
    before { member.update(roles: %w[lead]) }

    it_behaves_like '003-2 new user'
    it_behaves_like '003-2 edit user'
  end

  context 'board' do
    before { member.update(roles: %w[board]) }

    it_behaves_like '003-2 new user'
    it_behaves_like '003-2 edit user'
  end

  context 'admin' do
    before { member.update(roles: %w[admin]) }

    it_behaves_like '003-2 new user'
    it_behaves_like '003-2 edit user'
  end
end
