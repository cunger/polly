require 'json'
require_relative 'user'

module Polly
  class Users
    def initialize(user_storage)
      @store = user_storage
      @users = @store.load
    end

    def add!(username, password)
      raise NameEmpty        if username.strip.empty?
      raise PasswordEmpty    if password.strip.empty?
      raise NameAlreadyTaken if already_taken? username

      @users << Polly::User.create(username, password)
      save!
    end

    def delete!(username)
      @users.delete_if { |user| user.name == username }
      save!
    end

    def authenticate!(username, password)
      fetch(username).authenticate! password
    end

    def fetch(username)
      @users.each do |user|
        return user if user.name == username
      end
      block_given? ? yield : raise(UserNotFound, username)
    end

    class UserNotFound        < RuntimeError; end
    class NameEmpty           < RuntimeError; end
    class PasswordEmpty       < RuntimeError; end
    class PasswordDoesntMatch < RuntimeError; end
    class NameAlreadyTaken    < RuntimeError; end

    private

    def already_taken?(username)
      @users.any? { |user| user.name == username }
    end

    def save!
      @store.save! @users
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
      json = users.map { |user| { 'name' => user.name, 'password' => user.password } }
                  .to_json
      File.write @file, json
    end
  end
end
