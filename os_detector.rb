module NODE_HAVEN

  module OS
   
    def windows?
        (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end
    
    def windows_x64?
      if OS.windows?
        ENV['PROCESSOR_ARCHITECTURE'] == "AMD64"
      end
    end
  
    def mac?
     (/darwin/ =~ RUBY_PLATFORM) != nil
    end
  
    def unix?
      !OS.windows?
    end
  
    def linux?
      OS.unix? and not OS.mac?
    end
  
    def jruby?
       RUBY_ENGINE == 'jruby'
    end

    def linux_variant
      r = { :distro => nil, :family => nil }
    
      if File.exists?('/etc/lsb-release')
        File.open('/etc/lsb-release', 'r').read.each_line do |line|
          r = { :distro => $1 } if line =~ /^DISTRIB_ID=(.*)/
        end
      end
    
      if File.exists?('/etc/debian_version')
        r[:distro] = 'Debian' if r[:distro].nil?
        r[:family] = 'Debian' if r[:variant].nil?
      elsif File.exists?('/etc/redhat-release') or File.exists?('/etc/centos-release')
        r[:family] = 'RedHat' if r[:family].nil?
        r[:distro] = 'CentOS' if File.exists?('/etc/centos-release')
      elsif File.exists?('/etc/SuSE-release')
        r[:distro] = 'SLES' if r[:distro].nil?
      end
    
      return r
    end

  end      
end
