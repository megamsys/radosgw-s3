require 'net/ssh'
require 'json'

module CEPH
  class Radosgw

    attr_reader :username, :ipaddress, :user_password, :uid
    def initialize(options)
      raise ArgumentError, "Missing :username." if !options[:username]
      raise ArgumentError, "Missing :ipaddress." if !options[:ipaddress]
      raise ArgumentError, "Missing :user_password." if !options[:user_password]

      @username = options.fetch(:username)
      @ipaddress = options.fetch(:ipaddress)
      @user_password = options.fetch(:user_password)
    end

  end
end
