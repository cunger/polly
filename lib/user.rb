require 'bcrypt'

module Polly

  # A user is uniquely determined by the user name, and is associated with
  # a password that is used to authenticate the user. The password is
  # encrypted when the user is created.
  #
  # * +User::create+ creates a user from a user name and clear text password,
  # encrypting the password before storing it.
  # * +User::load+ serves as a wrapper, creating a user object from a user name
  # and already encrypted password. This is mainly used when reading user info
  # from some storage.

  class User
    attr_reader :name, :password

    def initialize(name, password)
      @name = name
      @password = password
    end

    def self.create(name, password)
      new(name, BCrypt::Password.create(password))
    end

    def self.load(name, password)
      new(name, BCrypt::Password.new(password))
    end

    def signed_in?
      true
    end

    def update_password(new_password, new_password_repeated)
      raise Polly::Users::PasswordEmpty       if new_password.strip.empty?
      raise Polly::Users::PasswordDoesntMatch if new_password != new_password_repeated

      @password = BCrypt::Password.create new_password
    end
  end

  # A guest user is the default when a website visitor is not signed in.

  class GuestUser
    def name
      'guest'
    end

    def signed_in?
      false
    end
  end
end
