require 'colorize'
require 'json'
require 'geocoder'
require 'socket'
require 'open-uri'
require 'logger'
require 'yaml' 
require 'csv'
require 'zip'
require_relative 'os_detector.rb'
require_relative 'installer'

module NODE_HAVEN
  module VMmanage
    def get7ZipPath
      path1 = "C:\\Program Files\\7-zip\\7z.exe"
      path2 = "C:\\Program Files (x86)\\7-zip\\7z.exe"
    
      if File.exists?(path1)
        return path1
      elsif File.exists?(path2)
        return path2
      else
        return ""
      end  
    end
    
    def VMmanage.main
      
      # get System Information
      Installer.getSystemInfoCsv
      
      if Installer.virtualBoxExists == false
        return(false)
      end
      
      vboxpath = Installer.virtualBoxGetPath
      $vmgr_version = nil
    
      if vboxpath == ""
        return(false)
      end
      
      $zip = `#{get7ZipPath} e .\\NodeHavenUbuntu.ova`
      
      $found = $zip.each_line do |line| {line =~ /Everything is Ok/}
        
      if $found == nil
        $logger.debug("7z error!".red.bold)
        return(false)
      end
        
        
      if !File.file?("NodeHavenUbuntu.ova")
        $logger.debug("OVA not found after extraction!".red.bold)
        return(false)
      end
        
      Dir.chdir(vboxpath) do
        $vmgr_version = ` .\\VBoxManage.exe -v`
      end
      
      if(!$vmgr_version.include? "6.0.8")
        $logger.debug("VBoxManage v." + $vmgr_version)
        $logger.debug("virtualbox is not the correct version!".red.bold)
      end

      Dir.chdir(vboxpath) do
        $logger.debug("import #{__dir__}\\NodeHavenUbuntu.ova")
        $vmgr_import = `.\\vboxmanage import #{__dir__}\\NodeHavenUbuntu.ova`
      end
      
      $logger.debug("VM imported successfully.".green.bold)
      return true
    end
  end
end

# debug code for stand alone run
if 0 == 1
  $logger = Logger.new(STDOUT)
  #$logger.level = Logger::WARN
  $logger.level = Logger::DEBUG  
  include NODE_HAVEN
  include OS
  include Installer
  include VMmanage
  $logger.debug("Attention: Debug is enabled!".yellow.bold)   
  VMmanage.main
end