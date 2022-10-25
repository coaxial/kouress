# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  describe 'GET /index' do
    context 'when not logged in' do
      before { get pages_path }

      it 'is not accessible' do
        expect(request).to redirect_to login_path
      end
    end
  end
end
