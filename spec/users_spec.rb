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

  it 'can fetch the test user' do
    elaine = @users.fetch 'elaine'
    expect(elaine.name).to eq 'elaine'
  end

  it 'can authenticate the test user' do
    @users.authenticate! 'elaine', 'marley'
  end

  it 'can add and authenticate a new user' do
    @users.add! 'herman', 'toothrot'
    @users.authenticate! 'herman', 'toothrot'
  end

  it 'can delete a user' do
    @users.delete! 'elaine'
    expect { @users.fetch('elaine') }.to raise_error(Polly::Users::UserNotFound)
  end
end

describe Polly::User do
  before do
    @user = Polly::User.create('guybrush', 'threepwood')
  end

  it 'is signed in' do
    expect @user.signed_in?
  end

  it 'needs the correct password to authenticate' do
    expect @user.authenticate!('threepwood')
  end
end

describe Polly::GuestUser do
  it 'is not signed in' do
    expect(Polly::GuestUser.new.signed_in?).to be_falsey
  end
end
