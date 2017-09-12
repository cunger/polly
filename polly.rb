require 'dotenv'
Dotenv.load

require 'sinatra'
require 'sinatra/reloader' if development?
require 'sysrandom/securerandom'

require_relative 'lib/users'

USERS = File.expand_path(File.dirname(__FILE__)) +
        (test? ? '/spec' : '/lib') +
        '/data/users.json'

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
  begin
    username = params['username']
    password = params['password']

    @users.authenticate! username, password

    welcome username

  rescue Polly::Users::UserNotFound
    deny :signin, 'Cannot find a user with this name.'
  rescue Polly::User::AuthenticationFailure
    deny :signin, 'The password you entered is incorrect.'
  end
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

  rescue Polly::Users::NameAlreadyTaken
    deny :signup, 'This name is already taken.'
  end
end

# User account

get '/user-account' do
  restrict_to_signed_in_user

  haml :useraccount
end

post '/user-account/reset-password' do
  begin
    username     = params['username']
    old_password = params['old_password']
    new_password = params['new_password']

    @users.authenticate! username, old_password

    if new_password != params['new_password_repeated']
      render_with_message :useraccount, "Your entries for the new password don't match."
    end

    @users.fetch(username).update_password(new_password)
    render_with_message :useraccount, 'Successfully updated password.'

  rescue RuntimeError
    deny :useraccount, 'Authentication failed.'
  end
end

post '/user-account/delete' do
  begin
    username = params['username']
    password = params['password']

    @users.authenticate! username, password
    @users.delete! username

    redirect_with_message '/', "Delete user account for '#{username}'."

  rescue RuntimeError
    deny :useraccount, 'Authentication failed.'
  end
end

#### Helpers ####

helpers do
  def current_flash_message
    session.delete(:flash) || ''
  end
end

private

def restrict_to_signed_in_user
  deny 'You need to be signed in to do this.' unless @user.signed_in?
end

def deny(template=:index, message)
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
