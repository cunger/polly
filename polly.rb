# Polly is a simple Sinatra app for database-free user management.
# It allows a user to sign up, sign in, change the password, and
# delete the account.
# It stores user information in a JSON file, but the storage
# can relatively easily be swapped for something else.
#
# This is an exercise project, not meant for production.
#
# Author: Christina Unger

require 'dotenv'
Dotenv.load

require 'sinatra'
require 'sinatra/reloader' if development?
require 'sysrandom/securerandom'

require_relative 'lib/users'

SOURCES = test? ? '/spec' : '/lib'
HERE    = File.expand_path(File.dirname(__FILE__))
USERS   = HERE + SOURCES + '/data/users.json'

configure do
  enable :sessions
  set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }
end

before do
  @users = Polly::Users.new(Polly::JSONUserStorage.new(USERS))
  @user  = @users.fetch(session[:user]) { Polly::GuestUser.new }
end

#### Routes ####

# Landing page

get '/' do
  haml :index
end

# Sign in

get '/sign-in' do
  haml :signin
end

post '/sign-in' do
  username = params['username']
  password = params['password']

  after_authentification_of(username, password, :signin) do
    welcome username
  end
end

# Log out

get '/log-out' do
  session.clear
  redirect '/'
end

# Sign up

get '/sign-up' do
  haml :signup
end

post '/sign-up' do
  begin
    username = params['username']
    password = params['password']

    @users.add! username, password

    welcome username

  rescue Polly::Users::NameEmpty
    deny :signup, 'The user name cannot be empty.'
  rescue Polly::Users::PasswordEmpty
    deny :signup, 'The password cannot be empty.'
  rescue Polly::Users::NameAlreadyTaken
    deny :signup, 'Sorry, this user name is already taken.'
  end
end

# User account

get '/user-account' do
  restrict_to_signed_in_user

  haml :useraccount
end

post '/user-account/reset-password' do
  username              = params['username']
  old_password          = params['old_password']
  new_password          = params['new_password']
  new_password_repeated = params['new_password_repeated']

  after_authentification_of(username, old_password, :useraccount) do
    user = @users.fetch username
    begin
      user.update_password(new_password, new_password_repeated)
      render_with_message :useraccount, 'Successfully updated password.'
    rescue Polly::Users::PasswordEmpty
      render_with_message :useraccount, 'The new password cannot be empty.'
    rescue Polly::Users::PasswordDoesntMatch
      render_with_message :useraccount, "Your entries for the new password don't match."
    end
  end
end

post '/user-account/delete' do
  username = params['username']
  password = params['password']

  after_authentification_of(username, password, :useraccount) do
    @users.delete! username
    redirect_with_message '/', "Deleted user account of '#{username}'."
  end
end

#### Helpers ####

helpers do
  def current_flash_message
    session.delete(:flash) || ''
  end
end

private

def after_authentification_of(username, password, template)
  @users.authenticate! username, password

  yield if block_given?

rescue Polly::Users::UserNotFound
  deny template, 'Cannot find a user with this name.'
rescue Polly::Users::AuthenticationFailure
  deny template, 'The password you entered is incorrect.'
end

def restrict_to_signed_in_user
  deny 'You need to be signed in to do this.' unless @user.signed_in?
end

def deny(template = :index, message)
  session[:flash] = message
  halt 403, haml(template)
end

def welcome(username)
  session[:user] = username
  redirect_with_message '/', "Welcome, #{username}!"
end

def redirect_with_message(path, message)
  session[:flash] = message
  redirect path
end

def render_with_message(template, message)
  session[:flash] = message
  haml template
end
