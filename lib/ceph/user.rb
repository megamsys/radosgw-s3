module CEPH
  class User < Radosgw
    def execution(command)
      radosgw_json =
      begin
        Net::SSH.start( @ipaddress, @username, :password => @user_password, :non_interactive=>true ) do|ssh|
          radosgw_json = ssh.exec!(command)
        end
      rescue Timeout::Error
        return "Timed out Error"
      rescue Errno::EHOSTUNREACH
        return "Host unreachable Error"
      rescue Errno::ECONNREFUSED
        return "Connection refused Error"
      rescue Net::SSH::AuthenticationFailed
        return "Authentication failure Error"
      end
      return radosgw_json
    end

    def exists(uid)
      ceph_user_json = ""
      ceph_user_json = execution("sudo radosgw-admin user info --uid='#{uid}'")
      begin
        JSON.parse(ceph_user_json)
        return true
      rescue JSON::ParserError => e
      return false
      end
    end

    def create(uid, display_name)
      ceph_user_json = ""
      ceph_user_json = execution("sudo radosgw-admin user create --uid='#{uid}'  --display-name='#{display_name}'")
      begin
        ceph_user_hash = JSON.parse(ceph_user_json)
        secret_hash = {"access_key" => "#{ceph_user_hash['keys'][0]['access_key']}", "secret_key" => "#{ceph_user_hash['keys'][0]['secret_key']}" }
        secret_hash
      rescue JSON::ParserError => e
      return ceph_user_json
      end
    end

    def usage(uid)
      user_usage_json = ""
      if exists(uid)
        user_usage_json = execution("sudo radosgw-admin user stats --uid='#{uid}'")

        if user_usage_json.include? "ERROR: can't read user header: (2) No such file or directory"
          usage_hash = {"total_objects" => "0", "total_bytes" => "0", "last_update" => "#{Time.now}" }
        else
          begin
            user_usage_hash = JSON.parse(user_usage_json)
            usage_hash = {"total_objects" => "#{user_usage_hash['stats']['total_entries']}", "total_bytes" => "#{user_usage_hash['stats']['total_bytes_rounded']}", "last_update" => "#{user_usage_hash['last_stats_update']}" }
            usage_hash
          rescue JSON::ParserError => e
          return user_usage_json
          end
        end
      else
        return "could not fetch user info: no user info saved"
      end
    end

  end
end
