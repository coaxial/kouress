# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Documents', type: :request do
  describe 'GET /index' do
    context 'when not logged in' do
      before { get documents_path }

      it 'is inaccessible' do
        expect(request).to redirect_to(login_path)
      end
    end
  end
end
