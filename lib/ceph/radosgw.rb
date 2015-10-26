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



    def user_create(uid, display_name)
	ceph_user_json = ""
	Net::SSH.start( @ipaddress, @username, :password => @user_password ) do|ssh| 
		ceph_user_json = ssh.exec!("sudo radosgw-admin user create --uid='#{uid}'  --display-name='#{display_name}'")
	end


    ceph_user_hash = JSON.parse(ceph_user_json)
    secret_hash = {"access_key" => "#{ceph_user_hash['keys'][0]['access_key']}", "secret_key" => "#{ceph_user_hash['keys'][0]['secret_key']}" }
    secret_hash
    end

    def user_usage(uid)
	user_usage_json = ""
	Net::SSH.start( @ipaddress, @username, :password => @user_password ) do|ssh| 
		user_usage_json = ssh.exec!("sudo radosgw-admin user stats --uid='#{uid}'")
	end

    if user_usage_json.include? "ERROR: can't read user header: (2) No such file or directory"
	usage_hash = {"total_objects" => "0", "total_bytes" => "0", "last_update" => "#{Time.now}" }
    else
    user_usage_hash = JSON.parse(user_usage_json)
    usage_hash = {"total_objects" => "#{user_usage_hash['stats']['total_entries']}", "total_bytes" => "#{user_usage_hash['stats']['total_bytes_rounded']}", "last_update" => "#{user_usage_hash['last_stats_update']}" }
    usage_hash
    end
    end

  end
end
