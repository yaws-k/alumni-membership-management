require 'rails_helper'

RSpec.describe 'Events', type: :request do
  let(:user) { create(:user) }
  let(:member) { user.member }

  let(:event) { create(:event) }

  let(:create_event_param) do
    {
      event_name: 'New event name',
      event_date: Date.today + 30,
      fee: 3000,
      payment_only: false,
      note: '備考'
    }
  end

  let(:update_event_param) do
    {
      event_name: 'Updated event name',
      fee: 1000
    }
  end

  # Not logged in
  context 'not logged in' do
    describe '#index' do
      it 'returns http redirect' do
        get '/events'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#show' do
      it 'returns http redirect' do
        get "/events/#{event.id}"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#new' do
      it 'returns http redirect' do
        get '/events/new'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#create' do
      it 'returns http redirect' do
        post '/events', params: { event: create_event_param }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#edit' do
      it 'returns http redirect' do
        get "/events/#{event.id}/edit"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#update' do
      it 'returns http redirect' do
        patch "/events/#{event.id}", params: { event: update_event_param }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#destroy' do
      it 'returns http redirect' do
        delete "/events/#{event.id}"
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
      it 'returns http success' do
        get '/events'
        expect(response).to have_http_status(:success)
      end
    end

    describe '#show' do
      it 'returns http success' do
        get "/events/#{event.id}"
        expect(response).to have_http_status(:success)
      end
    end

    describe '#new' do
      it 'returns http redirect' do
        get '/events/new'
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#create' do
      it 'returns http redirect' do
        post '/events', params: { event: create_event_param }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#edit' do
      it 'returns http redirect' do
        get "/events/#{event.id}/edit"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#update' do
      it 'returns http redirect' do
        patch "/events/#{event.id}", params: { event: update_event_param }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#destroy' do
      it 'returns http redirect' do
        delete "/events/#{event.id}"
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
      it 'returns http success' do
        get '/events'
        expect(response).to have_http_status(:success)
      end
    end

    describe '#show' do
      it 'returns http success' do
        get "/events/#{event.id}"
        expect(response).to have_http_status(:success)
      end
    end

    describe '#new' do
      it 'returns http redirect' do
        get '/events/new'
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#create' do
      it 'returns http redirect' do
        post '/events', params: { event: create_event_param }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#edit' do
      it 'returns http redirect' do
        get "/events/#{event.id}/edit"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#update' do
      it 'returns http redirect' do
        patch "/events/#{event.id}", params: { event: update_event_param }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#destroy' do
      it 'returns http redirect' do
        delete "/events/#{event.id}"
        expect(response).to redirect_to(members_path)
      end
    end
  end

  # Board
  context 'board' do
    before do
      member.update(roles: %w[board])
      sign_in user
    end

    describe '#index' do
      it 'returns http success' do
        get '/events'
        expect(response).to have_http_status(:success)
      end
    end

    describe '#show' do
      it 'returns http success' do
        get "/events/#{event.id}"
        expect(response).to have_http_status(:success)
      end
    end

    describe '#new' do
      it 'returns http success' do
        get '/events/new'
        expect(response).to have_http_status(:success)
      end
    end

    describe '#create' do
      it 'returns http redirect (success)' do
        post '/events', params: { event: create_event_param }
        expect(response).to redirect_to(events_path)
      end
    end

    describe '#edit' do
      it 'returns http success' do
        get "/events/#{event.id}/edit"
        expect(response).to have_http_status(:success)
      end
    end

    describe '#update' do
      it 'returns http redirect (success)' do
        patch "/events/#{event.id}", params: { event: update_event_param }
        expect(response).to redirect_to(events_path)
      end
    end

    describe '#destroy' do
      it 'returns http redirect (success)' do
        delete "/events/#{event.id}"
        expect(response).to redirect_to(events_path)
      end
    end
  end
end
