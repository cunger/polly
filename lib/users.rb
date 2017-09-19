require 'json'
require_relative 'user'

module Polly

  # A collection of users. It can authenticate, add and delete users,
  # as well as fetch a particular user based on the user name.
  # Requires a user storage, from which it can load the user information
  # and to which it can save it after making changes.

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

    def authenticate!(username, alleged_password)
      user = fetch username
      raise AuthenticationFailure unless user.password == alleged_password
    end

    def fetch(username)
      @users.each do |user|
        return user if user.name == username
      end
      block_given? ? yield : raise(UserNotFound, username)
    end

    class UserNotFound          < RuntimeError; end
    class NameEmpty             < RuntimeError; end
    class PasswordEmpty         < RuntimeError; end
    class PasswordDoesntMatch   < RuntimeError; end
    class NameAlreadyTaken      < RuntimeError; end
    class AuthenticationFailure < RuntimeError; end

    private

    def already_taken?(username)
      @users.any? { |user| user.name == username }
    end

    def save!
      @store.save! @users
    end
  end

  # User storage that saves and loads user names and passwords in a JSON file.

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
