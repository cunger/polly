require 'rspec'
require 'simplecov'
SimpleCov.start

require_relative '../lib/users'

describe Polly::Users do
  before do
    @users = Polly::Users.new(Polly::JSONUserStorage.new(users_json))
  end
  after do
    restore_users_json!
  end

  it 'can authenticate the test user' do
    @users.authenticate! 'elaine', 'marley'
  end

  it 'can fetch the test user' do
    elaine = @users.fetch 'elaine'
    expect(elaine.name).to eq 'elaine'
  end

  it 'can add and authenticate a new user' do
    @users.add! 'herman', 'toothrot'
    @users.authenticate! 'herman', 'toothrot'
  end
end

describe Polly::User do
end

describe Polly::GuestUser do
end
