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
end
