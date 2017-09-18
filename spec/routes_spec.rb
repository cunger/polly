require 'rspec'
require 'simplecov'
SimpleCov.start

require_relative 'spec_helper'

describe 'Application' do
  after do
    restore_users_json!
  end

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
      post '/sign-in', ELAINE
      follow_redirect!
      expect(last_response).to be_ok
      expect(last_response.body).to include "Welcome, elaine!"
      expect(last_response.body).to include "You're browsing as: elaine"
    end

    it 'does not succeed if the user name does not exist' do
      post '/sign-in', ELAINE_WITH_WRONG_USERNAME
      expect(last_response.body).to include 'Cannot find a user with this name.'
    end

    it 'does not succeed if the password is wrong' do
      post '/user-account/delete', ELAINE_WITH_WRONG_PASSWORD
      expect(last_response.body).to include 'The password you entered is incorrect.'
    end
  end

  describe 'The sign-up page' do
    it 'is available' do
      get '/sign-up'
      expect(last_response).to be_ok
    end

    it 'automatically signs in the new user' do
      post '/sign-up', GUYBRUSH
      follow_redirect!
      expect(last_response).to be_ok
      expect(last_response.body).to include "Welcome, guybrush!"
      expect(last_response.body).to include "You're browsing as: guybrush"
    end

    it 'does not succeed if the user name is empty' do
      post '/sign-up', ELAINE_WITH_EMPTY_USERNAME
      expect(last_response.body).to include 'The user name cannot be empty.'
    end

    it 'does not succeed if the password is empty' do
      post '/sign-up', ELAINE_WITH_EMPTY_PASSWORD
      expect(last_response.body).to include 'The password cannot be empty.'
    end

    it 'does not succeed if the user name is already taken' do
      post '/sign-up', ELAINE
      expect(last_response.body).to include 'Sorry, this user name is already taken.'
    end
  end

  describe 'The user account page' do
    it 'can be accessed by a logged in user' do
      get '/user-account', {}, as_user('elaine')
      expect(last_response).to be_ok
    end

    it 'cannot be accessed by the guest user' do
      get '/user-account'
      expect(last_response.status).to eq 403
    end

    context 'if authentication succeeded' do
      it 'allows the user to delete the account' do
        post '/user-account/delete', ELAINE
        follow_redirect!
        expect(last_response).to be_ok
        expect(last_response.body).to include "Deleted user account of 'elaine'."
        expect(last_response.body).to include "You're browsing as: guest"
      end

      it 'allows the user to change the password' do
        post '/user-account/reset-password', ELAINE_WITH_NEW_PASSWORD
        expect(last_response).to be_ok
        expect(last_response.body).to include 'Successfully updated password.'
      end

      it 'unless the new password is empty' do
        post '/user-account/reset-password', ELAINE_WITH_NEW_EMPTY_PASSWORD
        expect(last_response).to be_ok
        expect(last_response.body).to include 'The new password cannot be empty.'
      end

      it 'unless the new password entries do not match' do
        post '/user-account/reset-password', ELAINE_WITH_NEW_TYPO_PASSWORD
        expect(last_response).to be_ok
        expect(last_response.body).to include "Your entries for the new password don't match."
      end
    end

    context 'if authentication failed' do
      it 'does not allow the user to delete the account' do
        post '/user-account/delete', ELAINE_WITH_WRONG_PASSWORD
        expect(last_response.status).to eq 403
      end

      it 'does not allow the user to change the password' do
        post '/user-account/reset-password', ELAINE_WITH_WRONG_PASSWORD
        expect(last_response.status).to eq 403
      end
    end
  end

  private

  ELAINE   = { 'username' => 'elaine',   'password' => 'marley' }
  GUYBRUSH = { 'username' => 'guybrush', 'password' => 'threepwood' }

  ELAINE_WITH_WRONG_USERNAME = { 'username' => 'elain',  'password' => 'marley' }
  ELAINE_WITH_WRONG_PASSWORD = { 'username' => 'elaine', 'password' => 'threepwood' }
  ELAINE_WITH_EMPTY_USERNAME = { 'username' => '',       'password' => 'marley' }
  ELAINE_WITH_EMPTY_PASSWORD = { 'username' => 'elaine', 'password' => '' }

  ELAINE_WITH_NEW_PASSWORD       = { 'username' => 'elaine',
                                     'old_password' => 'marley',
                                     'new_password' => 'threepwood',
                                     'new_password_repeated' => 'threepwood' }
  ELAINE_WITH_NEW_EMPTY_PASSWORD = { 'username' => 'elaine',
                                     'old_password' => 'marley',
                                     'new_password' => ' ',
                                     'new_password_repeated' => ' ' }
  ELAINE_WITH_NEW_TYPO_PASSWORD  = { 'username' => 'elaine',
                                     'old_password' => 'marley',
                                     'new_password' => 'threepwood',
                                     'new_password_repeated' => 'threeepwood' }
end
