ENV['RACK_ENV'] = 'test'

require_relative '../lib/users'

require 'rspec'
require 'simplecov'
SimpleCov.start

describe Polly::Users do
end

describe Polly::User do
end

describe Polly::GuestUser do
end
