require 'rails_helper'

RSpec.describe '003-3s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'
  include_context 'login'
  let!(:address) { create(:address, :full_fields, member_id: member.id) }

  RSpec.shared_examples 'new address' do
    before do
      visit member_path(member)
      click_link('住所登録', href: new_member_address_path(member))
    end

    context 'check fields' do
      it 'shows new address link' do
        visit member_path(member)
        expect(page).to have_link('住所登録', href: new_member_address_path(member))
      end

      it 'shows input fields' do
        expect(page).to have_field('address_postal_code')
        expect(page).to have_field('address_address1')
        expect(page).to have_field('address_address2')
        expect(page).to have_field('address_unreachable')
      end
    end

    context 'create' do
      before do
        fill_in('address_postal_code', with: '100-0005')
        fill_in('address_address1', with: '東京都千代田区丸の内1-9-1')
        fill_in('address_address2', with: '東京駅')
        click_button('送信')
      end

      it 'redirects to member detail page' do
        expect(current_path).to eq(member_path(member))
      end

      it 'shows created address' do
        within(id: 'postalAddress') do
          expect(page).to have_text('有効')
          expect(page).to have_text('100-0005')
          expect(page).to have_text('東京都千代田区丸の内1-9-1')
          expect(page).to have_text('東京駅')
        end
      end
    end
  end

  RSpec.shared_examples 'edit address' do
    before do
      visit member_path(member)
      click_link('編集', href: edit_member_address_path(member, address))
    end

    context 'check fields' do
      it 'shows edit address link' do
        visit member_path(member)
        expect(page).to have_link('編集', href: edit_member_address_path(member, address))
      end

      it 'shows input fields' do
        expect(page).to have_field('address_postal_code')
        expect(page).to have_field('address_address1')
        expect(page).to have_field('address_address2')
        expect(page).to have_field('address_unreachable')
      end
    end

    context 'update' do
      it 'redirects to member detail page' do
        fill_in('address_postal_code', with: '100-0006')
        fill_in('address_address1', with: '東京都千代田区有楽町2-9-17')
        fill_in('address_address2', with: '有楽町駅')
        check('address_unreachable')
        click_button('送信')

        expect(current_path).to eq(member_path(member))
        within(id: 'postalAddress') do
          expect(page).to have_text('不達')
          expect(page).to have_text('100-0006')
          expect(page).to have_text('東京都千代田区有楽町2-9-17')
          expect(page).to have_text('有楽町駅')
        end
      end
    end

    context 'convert input' do
      it 'converts postal code (1)' do
        fill_in('address_postal_code', with: '１００ー0005')
        click_button('送信')
        expect(page).to have_text('100-0005')
      end

      it 'converts postal code (2)' do
        fill_in('address_postal_code', with: '１００0005')
        click_button('送信')
        expect(page).to have_text('100-0005')
      end

      it 'converts address' do
        fill_in('address_address1', with: '東京都千代田区有楽町２ー9-17')
        click_button('送信')
        expect(page).to have_text('東京都千代田区有楽町2-9-17')
      end
    end
  end

  context 'normal user' do
    it_behaves_like 'new address'
    it_behaves_like 'edit address'
  end

  context 'lead' do
    before { member.update(roles: %w[lead]) }

    it_behaves_like 'new address'
    it_behaves_like 'edit address'
  end

  context 'board' do
    before { member.update(roles: %w[board]) }

    it_behaves_like 'new address'
    it_behaves_like 'edit address'
  end

  context 'admin' do
    before { member.update(roles: %w[admin]) }

    it_behaves_like 'new address'
    it_behaves_like 'edit address'
  end
end
