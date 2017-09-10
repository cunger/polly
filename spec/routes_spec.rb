require 'rspec'
require 'simplecov'
SimpleCov.start

require_relative 'spec_helper'

describe 'Application' do
  describe 'the landing page' do
    it 'should be ok' do
      get '/'
      expect(last_response).to be_ok
    end
  end

  describe 'the user' do
    context 'when not logged in' do
      before do
        @user = Polly::GuestUser.new
      end

      it 'should browse as guest' do
        get '/'
        expect(last_response.body).to include "You're browsing as guest."
      end
    end

    context 'when logged in' do
      before do
        @user = Polly::User.new('Polly', 'secret')
      end

      it 'should browse as that user' do
        get '/'
        expect(last_response.body).to include "You're browsing as Polly."
      end
    end
  end
end
