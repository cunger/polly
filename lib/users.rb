require 'json'
require_relative 'user'

module Polly
  class Users
    def initialize(user_storage)
      @store = user_storage
      @users = @store.load
    end

    def add!(username, password)
      raise NameAlreadyTaken if already_taken? username

      @users << Polly::User.create(username, password)
      @store.save! @users
    end

    def authenticate!(username, password)
      fetch(username).authenticate! password
    end

    def fetch(username)
      @users.each do |user|
        return user if user.name == username
      end
      block_given? ? yield : raise(UserNotFound)
    end

    class UserNotFound < RuntimeError ; end
    class NameAlreadyTaken < RuntimeError ; end

    private

    def already_taken?(username)
      @users.any? { |user| user.name == username }
    end
  end

  class JSONUserStorage
    def initialize(file)
      @file = file
    end

    def load
      json = JSON.parse File.read(@file)
      json.map { |info| Polly::User.load(info['name'], info['password']) }
    end

    def save!(users)
      users.map { |user| { 'name': user.name, 'password': user.password } }
      File.write @file, users.to_json
    end
  end
end
