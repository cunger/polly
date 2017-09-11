require 'rspec'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

require_relative '../polly'

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
    { 'rack.session' => { :user => name } }
  end
end

RSpec.configure do |config|
  config.include RSpecMixin
  config.default_formatter = 'doc'
end
