require 'rspec'
require 'simplecov'
SimpleCov.start

require_relative 'spec_helper'

describe 'Application' do
  describe 'The landing page' do
    it 'should be ok' do
      get '/'
      expect(last_response).to be_ok
    end
  end

  describe 'The user' do
    context 'when not logged in' do
      it 'should browse as guest' do
        get '/'
        expect(last_response.body).to include "You're browsing as: guest"
      end
    end

    context 'when logged in' do
      it 'should browse as that user' do
        get '/', {}, as_user('elaine')
        expect(last_response.body).to include "You're browsing as: elaine"
      end
    end
  end

  describe 'The sign-in page' do
    it 'is available' do
      get '/sign-in'
      expect(last_response).to be_ok
    end

    it 'signs in the user' do
      post '/sign-in', { 'username': 'elaine', 'password': 'marley' }
      follow_redirect!
      expect(last_response).to be_ok
      expect(last_response.body).to include "Welcome, elaine!"
      expect(last_response.body).to include "You're browsing as: elaine"
    end
  end

  describe 'The sign-up page' do
    it 'is available' do
      get '/sign-up'
      expect(last_response).to be_ok
    end

    it 'automatically signs in the new user' do
      post '/sign-up', { 'username': 'guybrush', 'password': 'threepwood' }
      follow_redirect!
      expect(last_response).to be_ok
      expect(last_response.body).to include "Welcome, guybrush!"
      expect(last_response.body).to include "You're browsing as: guybrush"
    end

    it 'complains if the user name is already taken' do
      post '/sign-up', { 'username': 'elaine', 'password': 'threepwood' }
      expect(last_response.status).to eq 403
      expect(last_response.body).to include 'This name is already taken.'
    end
  end

  describe 'The user account page' do
    it 'can be accessed by a logged in user' do
      get '/user-account', {}, as_user('elaine')
      expect(last_response).to be_ok
    end

    it 'cannot be accessed by the guest user' do
      get '/user-account'
      expect(last_response.status).to eq(403)
    end

    context 'if authentication succeeded' do
      it 'allows the user to delete the account' do
        fail
        # as a result, the user browses as guest again
      end

      it 'allows the user to change the password' do
        fail
      end

      it 'unless the new password entries do not match' do
        fail
      end
    end

    context 'if authentication failed' do
      it 'does not allow the user to delete the account' do
        fail
      end

      it 'does not allow the user to change the password' do
        fail
      end
    end
  end
end
