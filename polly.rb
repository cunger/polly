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

get '/' do
  haml :index
end

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
  rescue Polly::User::InvalidPassword
    deny :signin, 'The password you entered is incorrect.'
  end
end

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

#### Helpers ####

helpers do
  def current_flash_message
    session.delete(:flash) || ''
  end
end

private

def deny(template, message)
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
