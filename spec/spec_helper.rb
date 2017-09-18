require 'rspec'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

require_relative '../polly'
require_relative '../lib/users'

module RSpecMixin
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  private

  def session
    last_request.env['rack.session']
  end

  def as_user(name)
    { 'rack.session' => { user: name } }
  end

  DIR = File.expand_path(File.dirname(__FILE__))

  def users_json
    DIR + '/data/users.json'
  end

  def restore_users_json!
    original_file = DIR + '/data/users_init.json'
    current_file  = DIR + '/data/users.json'
    File.write(current_file, File.read(original_file))
  end
end

RSpec.configure do |config|
  config.include RSpecMixin
  config.default_formatter = 'doc'
end
