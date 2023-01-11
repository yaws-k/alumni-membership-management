require 'rails_helper'

RSpec.describe 'Attendances', type: :request do
  let(:user) { create(:user) }
  let(:member) { user.member }
  let(:attendance) { create(:attendance, member_id: member.id) }

  let(:member2) { create(:member, year_id: member.year_id) }
  let(:attendance2) { create(:attendance, member_id: member2.id) }

  let(:attendance3) { create(:attendance) }
  let(:member3) { attendance3.member }

  let(:edit_attendance_param) do
    {
      application: true,
      note: '更新'
    }
  end

  include ActionView::RecordIdentifier

  # Not logged in
  context 'not logged in' do
    describe '#edit' do
      it 'returns http redirect' do
        get "/attendances/#{attendance.id}/edit"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#update' do
      it 'returns http redirect' do
        patch "/attendances/#{attendance.id}", params: {
          attendance: edit_attendance_param
        }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  # Normal user
  context 'normal user' do
    before do
      sign_in user
    end

    describe '#edit' do
      it 'returns http success to own data' do
        get "/attendances/#{attendance.id}/edit"
        expect(response).to have_http_status(:success)
      end

      it "returns http redirect to same year member's data" do
        get "/attendances/#{attendance2.id}/edit"
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect to other member's data" do
        get "/attendances/#{attendance3.id}/edit"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#update' do
      it 'retuns http redirect (success) to own data' do
        patch "/attendances/#{attendance.id}", params: {
          attendance: edit_attendance_param
        }
        expect(response).to redirect_to(member_path(member, anchor: dom_id(attendance)))
      end

      it "returns http redirect (reject) to same year member's data" do
        patch "/attendances/#{attendance2.id}", params: {
          attendance: edit_attendance_param
        }
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect (reject) to other member's data" do
        patch "/attendances/#{attendance3.id}", params: {
          attendance: edit_attendance_param
        }
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

    describe '#edit' do
      it 'returns http success to own data' do
        get "/attendances/#{attendance.id}/edit"
        expect(response).to have_http_status(:success)
      end

      it "returns http success to same year member's data" do
        get "/attendances/#{attendance2.id}/edit"
        expect(response).to have_http_status(:success)
      end

      it "returns http redirect to other member's data" do
        get "/attendances/#{attendance3.id}/edit"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#update' do
      it 'retuns http redirect (success) to own data' do
        patch "/attendances/#{attendance.id}", params: {
          attendance: edit_attendance_param
        }
        expect(response).to redirect_to(member_path(member, anchor: dom_id(attendance)))
      end

      it "returns http redirect (success) to same year member's data" do
        patch "/attendances/#{attendance2.id}", params: {
          attendance: edit_attendance_param
        }
        expect(response).to redirect_to(member_path(member2, anchor: dom_id(attendance2)))
      end

      it "returns http redirect (reject) to other member's data" do
        patch "/attendances/#{attendance3.id}", params: {
          attendance: edit_attendance_param
        }
        expect(response).to redirect_to(members_path)
      end
    end
  end

  # Board
  context 'board member' do
    before do
      member.update(roles: %w[board])
      sign_in user
    end

    describe '#edit' do
      it 'returns http success to own data' do
        get "/attendances/#{attendance.id}/edit"
        expect(response).to have_http_status(:success)
      end

      it "returns http success to same year member's data" do
        get "/attendances/#{attendance2.id}/edit"
        expect(response).to have_http_status(:success)
      end

      it "returns http success to other member's data" do
        get "/attendances/#{attendance3.id}/edit"
        expect(response).to have_http_status(:success)
      end
    end

    describe '#update' do
      it 'retuns http redirect (success) to own data' do
        patch "/attendances/#{attendance.id}", params: {
          attendance: edit_attendance_param
        }
        expect(response).to redirect_to(member_path(member, anchor: dom_id(attendance)))
      end

      it "returns http redirect (success) to same year member's data" do
        patch "/attendances/#{attendance2.id}", params: {
          attendance: edit_attendance_param
        }
        expect(response).to redirect_to(member_path(member2, anchor: dom_id(attendance2)))
      end

      it "returns http redirect (reject) to other member's data" do
        patch "/attendances/#{attendance3.id}", params: {
          attendance: edit_attendance_param
        }
        expect(response).to redirect_to(member_path(member3, anchor: dom_id(attendance3)))
      end
    end
  end

  # Admin
  context 'admin' do
    # The same as board member.
    # Details should be tested with system specs.
  end
end
