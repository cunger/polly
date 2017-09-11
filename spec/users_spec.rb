ENV['RACK_ENV'] = 'test'

require_relative '../lib/users'

require 'rspec'
require 'simplecov'
SimpleCov.start

describe Polly::Users do
  before do
    @users = Polly::Users.new
  end

  it 'can fetch and validate test user' do
    polly = @users.fetch 'polly'
    expect(polly.name).to eq 'polly'
    expect(polly.valid_password?('wantscrack'))
  end
end

describe Polly::User do
end

describe Polly::GuestUser do
end
