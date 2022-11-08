require 'rails_helper'

RSpec.describe 'Payments', type: :request do
  let(:user) { create(:user) }
  let(:member) { user.member }

  let(:payment) { create(:event, :payment) }

  let(:create_payment_param) do
    {
      event_name: 'New payment name',
      event_date: Date.today + 30,
      fee: 3000,
      payment_only: true,
      note: '備考'
    }
  end

  let(:update_payment_param) do
    {
      event_name: 'Updated payment name',
      fee: 1000
    }
  end

  # Not logged in
  context 'not logged in' do
    describe '#index' do
      it 'returns http redirect' do
        get '/payments'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#show' do
      it 'returns http redirect' do
        get "/payments/#{payment.id}"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#new' do
      it 'returns http redirect' do
        get '/payments/new'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#create' do
      it 'returns http redirect' do
        post '/payments', params: { event: create_payment_param }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#edit' do
      it 'returns http redirect' do
        get "/payments/#{payment.id}/edit"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#update' do
      it 'returns http redirect' do
        patch "/payments/#{payment.id}", params: { event: update_payment_param }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#destroy' do
      it 'returns http redirect' do
        delete "/payments/#{payment.id}"
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
        get '/payments'
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#show' do
      it 'returns http redirect' do
        get "/payments/#{payment.id}"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#new' do
      it 'returns http redirect' do
        get '/payments/new'
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#create' do
      it 'returns http redirect' do
        post '/payments', params: { event: create_payment_param }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#edit' do
      it 'returns http redirect' do
        get "/payments/#{payment.id}/edit"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#update' do
      it 'returns http redirect' do
        patch "/payments/#{payment.id}", params: { event: update_payment_param }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#destroy' do
      it 'returns http redirect' do
        delete "/payments/#{payment.id}"
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
        get '/payments'
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#show' do
      it 'returns http redirect' do
        get "/payments/#{payment.id}"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#new' do
      it 'returns http redirect' do
        get '/payments/new'
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#create' do
      it 'returns http redirect' do
        post '/payments', params: { event: create_payment_param }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#edit' do
      it 'returns http redirect' do
        get "/payments/#{payment.id}/edit"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#update' do
      it 'returns http redirect' do
        patch "/payments/#{payment.id}", params: { event: update_payment_param }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#destroy' do
      it 'returns http redirect' do
        delete "/payments/#{payment.id}"
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
      it 'returns http success' do
        get '/payments'
        expect(response).to have_http_status(:success)
      end
    end

    describe '#show' do
      it 'returns http success' do
        get "/payments/#{payment.id}"
        expect(response).to have_http_status(:success)
      end
    end

    describe '#new' do
      it 'returns http success' do
        get '/payments/new'
        expect(response).to have_http_status(:success)
      end
    end

    describe '#create' do
      it 'returns http redirect (success)' do
        post '/payments', params: { event: create_payment_param }
        expect(response).to redirect_to(payments_path)
      end
    end

    describe '#edit' do
      it 'returns http success' do
        get "/payments/#{payment.id}/edit"
        expect(response).to have_http_status(:success)
      end
    end

    describe '#update' do
      it 'returns http redirect (success)' do
        patch "/payments/#{payment.id}", params: { event: update_payment_param }
        expect(response).to redirect_to(payments_path)
      end
    end

    describe '#destroy' do
      it 'returns http redirect (success)' do
        delete "/payments/#{payment.id}"
        expect(response).to redirect_to(payments_path)
      end
    end
  end
end
