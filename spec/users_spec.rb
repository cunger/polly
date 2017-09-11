ENV['RACK_ENV'] = 'test'

require_relative '../lib/users'

require 'rspec'
require 'simplecov'
SimpleCov.start

ENV['USERS_FILE'] = File.expand_path(File.dirname(__FILE__)) + '/data/users.json'

describe Polly::Users do
  before do
    @users = Polly::Users.new
  end

  it 'can fetch and validate the test user' do
    polly = @users.fetch 'elaine'
    expect(polly.name).to eq 'elaine'
    expect(polly.valid_password?('marley'))
  end

  it 'can add and fetch a new user' do
    @users << Polly::User.new('herman', 'toothrot')
    herman = @users.fetch 'herman'
    expect(herman.name).to eq 'herman'
    expect(herman.valid_password?('toothrot'))
  end
end

describe Polly::User do
end

describe Polly::GuestUser do
end
