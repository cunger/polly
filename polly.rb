require 'sinatra'
require 'sinatra/reloader' if development?

require 'sysrandom/securerandom'

require_relative 'lib/users'

configure do
  enable :sessions
  set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }
end

before do
  @user = Polly::Users.new.fetch
end

#### Routes ####

get '/' do
  haml :index
end

#### Helpers ####

helpers do
  def current_flash_message
    session.delete(:flash) || ''
  end
end
