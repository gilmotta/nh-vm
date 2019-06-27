module OS
  
  def OS.windows?
      (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end
  
    def OS.mac?
     (/darwin/ =~ RUBY_PLATFORM) != nil
    end
  
    def OS.unix?
      !OS.windows?
    end
  
    def OS.linux?
      OS.unix? and not OS.mac?
    end
  
    def OS.jruby?
       RUBY_ENGINE == 'jruby'
    end

    def OS.linux_variant
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
