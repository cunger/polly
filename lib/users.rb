require 'json'
require_relative 'user'

module Polly
  class Users
    def initialize
      @users = load_users
    end

    def <<(user)
      @users << user
    end

    def fetch(username)
      @users.each do |user| 
        return user if user.name == username
      end
      Polly::GuestUser.new
    end

    private

    def load_users
      file = File.expand_path(File.dirname(__FILE__)) + '/data/users.json'
      json = JSON.parse File.read(file)
      json.map { |info| Polly::User.new(info['name'], info['password']) }
    end
  end
end
