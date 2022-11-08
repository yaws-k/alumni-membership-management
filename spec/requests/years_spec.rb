require 'rails_helper'

RSpec.describe 'Years', type: :request do
  let(:user) { create(:user) }
  let(:member) { user.member }

  let(:year) { create(:year) }

  let(:create_year_param) do
    {
      graduate_year: '高80回',
      anno_domini: 2019,
      japanese_calendar: '令和2'
    }
  end

  let(:update_year_param) do
    {
      anno_domini: 2020
    }
  end

  # Not logged in
  context 'not logged in' do
    describe '#index' do
      it 'returns http redirect' do
        get '/years'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#new' do
      it 'returns http redirect' do
        get '/years/new'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#create' do
      it 'returns http redirect' do
        post '/years', params: { year: create_year_param }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#edit' do
      it 'returns http redirect' do
        get "/years/#{year.id}/edit"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#update' do
      it 'returns http redirect' do
        patch "/years/#{year.id}", params: { year: update_year_param }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#destroy' do
      it 'returns http redirect' do
        delete "/years/#{year.id}"
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  # Normal user
  context 'normal user' do
    before do
      sign_in user
    end

    describe '#index' do
      it 'returns http redirect' do
        get '/years'
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#new' do
      it 'returns http redirect' do
        get '/years/new'
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#create' do
      it 'returns http redirect' do
        post '/years', params: { year: create_year_param }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#edit' do
      it 'returns http redirect' do
        get "/years/#{year.id}/edit"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#update' do
      it 'returns http redirect' do
        patch "/years/#{year.id}", params: { year: update_year_param }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#destroy' do
      it 'returns http redirect' do
        delete "/years/#{year.id}"
        expect(response).to redirect_to(members_path)
      end
    end
  end

  # Lead
  context 'lead' do
    before do
      member.update(roles: %w[lead])
      sign_in user
    end

    describe '#index' do
      it 'returns http redirect' do
        get '/years'
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#new' do
      it 'returns http redirect' do
        get '/years/new'
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#create' do
      it 'returns http redirect' do
        post '/years', params: { year: create_year_param }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#edit' do
      it 'returns http redirect' do
        get "/years/#{year.id}/edit"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#update' do
      it 'returns http redirect' do
        patch "/years/#{year.id}", params: { year: update_year_param }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#destroy' do
      it 'returns http redirect' do
        delete "/years/#{year.id}"
        expect(response).to redirect_to(members_path)
      end
    end
  end

  # Board
  context 'lead' do
    before do
      member.update(roles: %w[board])
      sign_in user
    end

    describe '#index' do
      it 'returns http redirect' do
        get '/years'
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#new' do
      it 'returns http redirect' do
        get '/years/new'
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#create' do
      it 'returns http redirect (reject)' do
        post '/years', params: { year: create_year_param }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#edit' do
      it 'returns http redirect' do
        get "/years/#{year.id}/edit"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#update' do
      it 'returns http redirect (reject)' do
        patch "/years/#{year.id}", params: { year: update_year_param }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#destroy' do
      it 'returns http redirect (reject)' do
        delete "/years/#{year.id}"
        expect(response).to redirect_to(members_path)
      end
    end
  end

  # Admin
  context 'lead' do
    before do
      member.update(roles: %w[admin])
      sign_in user
    end

    describe '#index' do
      it 'returns http success' do
        get '/years'
        expect(response).to have_http_status(:success)
      end
    end

    describe '#new' do
      it 'returns http success' do
        get '/years/new'
        expect(response).to have_http_status(:success)
      end
    end

    describe '#create' do
      it 'returns http redirect (success)' do
        post '/years', params: { year: create_year_param }
        expect(response).to redirect_to(years_path)
      end
    end

    describe '#edit' do
      it 'returns http success' do
        get "/years/#{year.id}/edit"
        expect(response).to have_http_status(:success)
      end
    end

    describe '#update' do
      it 'returns http redirect (success)' do
        patch "/years/#{year.id}", params: { year: update_year_param }
        expect(response).to redirect_to(years_path)
      end
    end

    describe '#destroy' do
      it 'returns http redirect (success)' do
        delete "/years/#{year.id}"
        expect(response).to redirect_to(years_path)
      end
    end
  end
end
