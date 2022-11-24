require 'rails_helper'

RSpec.describe "011s", type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'
  include_context 'login'

  RSpec.shared_examples 'name conversion' do
    before do
      visit member_path(member)
      click_link('基本情報編集・削除', href: edit_member_path(member))
    end

    it 'rejects special characters' do
      fill_in('member_family_name', with: '名字(')
      fill_in('member_first_name', with: '名　前')
      fill_in('member_maiden_name', with: '（旧姓）')
      click_button('送信')

      within(class: 'alert alert-error') do
        expect(page).to have_text('名字に記号など不正な文字が入っています。')
        expect(page).to have_text('名前に記号など不正な文字が入っています。')
        expect(page).to have_text('旧姓に記号など不正な文字が入っています。')
      end
    end

    it 'converts names before save' do
      fill_in('member_family_name', with: '名字?')
      fill_in('member_first_name', with: 'ｶﾀｶﾅ')
      fill_in('member_maiden_name', with: ' 旧姓 ')
      click_button('送信')

      within(id: 'basicData') do
        expect(page).to have_text('？？？？？')
        expect(page).to have_text('カタカナ')
        expect(page).to have_text('旧姓')
      end
    end
  end

  context 'normal user' do
    it_behaves_like 'name conversion'
  end

  context 'lead' do
    before { member.update(roles: %w[lead]) }

    it_behaves_like 'name conversion'
  end

  context 'board' do
    before { member.update(roles: %w[board]) }

    it_behaves_like 'name conversion'
  end

  context 'admin' do
    before { member.update(roles: %w[admin]) }

    it_behaves_like 'name conversion'
  end
end
