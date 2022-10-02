require 'rails_helper'

RSpec.describe 'Members', type: :request do
  describe '#index' do
    it 'returns http success' do
      get '/members/index'
      expect(response).to have_http_status(:success)
    end
  end
end
