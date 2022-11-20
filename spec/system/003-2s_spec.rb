require 'rails_helper'

RSpec.describe '003-2s', type: :system do
  before do
    driven_by(:rack_test)
    user.update(password: 'currentPassword', password_confirmation: 'currentPassword')
  end

  include_context 'base user'
  include_context 'login'

  RSpec.shared_examples 'new user' do
    before { visit new_member_user_path(member) }

    context 'check fields' do
      it 'shows new user link' do
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
      it 'redirects to member detail page' do
        fill_in('user_email', with: 'new_mail@example.com')
        fill_in('user_password', with: 'difficultPassword')
        fill_in('user_password_confirmation', with: 'difficultPassword')
        click_button('送信')

        expect(current_path).to eq(member_path(member))
      end

      it 'shows created email' do
        fill_in('user_email', with: 'new_mail@example.com')
        fill_in('user_password', with: 'difficultPassword')
        fill_in('user_password_confirmation', with: 'difficultPassword')
        click_button('送信')

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

  RSpec.shared_examples 'edit user' do
    context 'check fields' do
      before { visit edit_member_user_path(member, user) }

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
        before { visit edit_member_user_path(member, user) }

        context 'email change only' do
          it 'redirects to member detail page' do
            fill_in('user_email', with: 'edit_mail@example.com')
            click_button('送信')

            expect(current_path).to eq(member_path(member))
            within(id: 'mailAddress') do
              expect(page).to have_text('edit_mail@example.com')
            end
          end

          it 'preserves old password' do
            fill_in('user_email', with: 'edit_mail@example.com')
            click_button('送信')
            click_button('Logout')

            visit new_user_session_path
            fill_in 'user_email', with: 'edit_mail@example.com'
            fill_in 'user_password', with: 'currentPassword'
            click_button 'ログイン'

            expect(page).to have_text('Signed in successfully.')
          end
        end

        context 'password change' do
          it 'redirects to login page' do
            fill_in('user_email', with: 'edit_mail@example.com')
            fill_in('user_password', with: 'editPassword')
            fill_in('user_password_confirmation', with: 'editPassword')
            click_button('送信')

            expect(current_path).to eq(new_user_session_path)
          end

          it 'updates password' do
            fill_in('user_email', with: 'edit_mail@example.com')
            fill_in('user_password', with: 'editPassword')
            fill_in('user_password_confirmation', with: 'editPassword')
            click_button('送信')

            visit new_user_session_path
            fill_in 'user_email', with: 'edit_mail@example.com'
            fill_in 'user_password', with: 'editPassword'
            click_button 'ログイン'

            expect(page).to have_text('Signed in successfully.')
          end
        end
      end

      context 'another email' do
        let(:user2) { create(:user, member_id: member.id) }
        before { visit edit_member_user_path(member, user2) }

        it 'redirects to member detail page' do
          fill_in('user_email', with: 'edit_mail@example.com')
          fill_in('user_password', with: 'editPassword')
          fill_in('user_password_confirmation', with: 'editPassword')
          check('user_unreachable')
          click_button('送信')

          expect(current_path).to eq(member_path(member))
          within(id: 'mailAddress') do
            expect(page).to have_text('不達')
            expect(page).to have_text('edit_mail@example.com')
          end
        end

        it 'updates password' do
          fill_in('user_email', with: 'edit_mail@example.com')
          fill_in('user_password', with: 'editPassword')
          fill_in('user_password_confirmation', with: 'editPassword')
          click_button('送信')
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
    it_behaves_like 'new user'
    it_behaves_like 'edit user'
  end

  context 'lead' do
    before { member.update(roles: %w[lead]) }

    it_behaves_like 'new user'
    it_behaves_like 'edit user'
  end

  context 'board' do
    before { member.update(roles: %w[board]) }

    it_behaves_like 'new user'
    it_behaves_like 'edit user'
  end

  context 'admin' do
    before { member.update(roles: %w[admin]) }

    it_behaves_like 'new user'
    it_behaves_like 'edit user'
  end
end
