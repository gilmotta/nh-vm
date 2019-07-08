#!/usr/bin/env ruby

  require 'colorize'
  require 'json'
  require 'geocoder'
  require 'socket'
  require 'open-uri'
  require 'logger'
  require 'yaml' 
  require 'csv'
  require_relative 'os_detector.rb'

  module NODE_HAVEN
    module Installer
  
      $systeminfocsv = nil  # system info results in CSV format
      $systeminfo = nil     # CSV object, serialized as an array $systeminfo["System Type"]
  
      def isWindowsx64
        $systeminfo["System Type"].include? "x64" == true
      end
      
      def isWindowsx86
        $systeminfo["System Type"].include? "x86" == true
      end
      
      def getSystemInfoCsv      
          if OS.windows?()
              # if running on windows
              # get the system info in CSV format
              $systeminfocsv = `systeminfo /fo CSV`
          
              File.write('systeminfo.csv', $systeminfocsv)
              
              $systeminfo = CSV.read("systeminfo.csv", headers:true)
          else
            
              $systeminfocsv = `sudo lshw -json`
            
          end          
      end
      
      def getSystemInfo      
          if OS.windows?()
              # if running on windows
              # get the system info in CSV format
              $systeminfocsv = `systeminfo /fo CSV`
          
              File.write('systeminfo.csv', $systeminfocsv)
              
              #$systeminfoCSV = CSV.read('systeminfo.csv', headers:true)
              #$systeminfo = $systeminfoCSV.to_json
              
              lines = CSV.open('systeminfo.csv').readlines
              keys = lines.delete lines.first
              
              File.open('systeminfo.json', 'w') do |f|
                data = lines.map do |values|
                  Hash[keys.zip(values)]
                end
                f.puts JSON.pretty_generate(data)
              end
    
              file = File.open('systeminfo.json')
              $systeminfo = file.read
          else
              $systeminfo = `sudo lshw -json`
          end
          return $systeminfo  
      end
    
=begin
    # ===================================================================================================================
    # ===================================================================================================================
    #
    #     Assumed files were downloaded by downloader
    #
    # ===================================================================================================================
    # ===================================================================================================================    
=end
    
      def install_files_on_windows(manifest)
    
        	#path1 = "vbox\\"
        	path1 = ""
        	logname = "nh-install.txt"
        		
            unless File.file?(path1 + manifest["install"])
              $logger.debug( "\nInstaller #{manifest["install"]} not found. Failed to install hypervisor on host.\n")
              exit(false)
            end
            
            # ==== STEP 1 oracle certificates
            #
            # certutil -addstore "TrustedPublisher" oracle.cer
            
            # install all certificates required to run the VM
            manifest['certs'].each do |certname|
              $logger.debug( certname.green.bold + " found.")
              system("certutil -addstore \"TrustedPublisher\" " + path1 + certname)
            end
            
            # ==== STEP 2 .msi or .exe
            filename = manifest["install"]
            
            $logger.debug("Installing " + "#{manifest["install"]} ...".green.bold)
            
            starting = Time.now
           
            # ==== calling shell to install the hypervisor
            #
            # msiexec /I VirtualBox-2.1.4-42893-Win_amd64.msi /Passive /NoRestart
            system("msiexec /I " + path1 + "#{manifest["install"]} /quiet /passive /norestart /log #{logname}")
            #
            # ====
            
            # time consuming operation
            ending = Time.now
            elapsed = ending - starting
            elapsed = elapsed/60 # in minutes
            
            $logger.debug("installation completed in #{elapsed} minutes")
                  
          	$logger.debug("file cleanup.")
          	
          	# make sure Vbox Manager is installed and working
            return(virtualBoxVersionCheckSuccess logname)
      end
    
=begin
    # ===================================================================================================================
    # ===================================================================================================================
    #
    #     VirtualBoxCheck
    #
    # ===================================================================================================================
    # ===================================================================================================================    
=end
    
    	def virtualBoxGetPath
    		vbox_x64path = "C:\\Program Files\\Oracle\\VirtualBox\\"
    		vbox_x86path = "C:\\Program Files (x86)\\Oracle\\VirtualBox\\"
    		
    		if isWindowsx64
    			return vbox_x64path
    		else   		  
    		  if File.directory?(vbox_x86path)	
    		    return vbox_x86path
    		  elsif File.directory?(vbox_x64path)
            # a 32 bit machine probably running Windows 8/10 
            return vbox_x64path
    		  else
    		    return ""
    		  end  
    		end
    	end
     
      def virtualBoxExists
      #MSI (s) (AC:C8) [15:37:53:960]: Product: Oracle VM VirtualBox 6.0.8 -- Installation completed successfully.
    	
    	vboxpath = virtualBoxGetPath
    	vmgr = "VBoxManage.exe"
    
        unless File.file?(vboxpath + vmgr)
          $logger.debug( "\n#{vboxpath + vmgr} not installed.\n".yellow.bold)
          return(false)
        end
    	
    	return(true)
      end
      
      def virtualBoxVersionCheckSuccess filename
  
        	  vboxpath = virtualBoxGetPath
          	$vmgr_version = nil
        	
          	if vboxpath == ""
          	  return(false)
          	end
          	  
          	Dir.chdir(vboxpath) do
          		$vmgr_version = ` .\\VBoxManage.exe -v`
          	end
          	
          	$logger.debug("VBoxManage v." + $vmgr_version.green.bold)
          	
          	if(!$vmgr_version.include? "6.0.8")
          		return(false)
          	end
          	
          	$found = nil
          	File.open filename do |file|
          		 $found = file.find {|line| line =~ /VirtualBox 6.0.8 -- Installation completed successfully/}
          	end
          	
          	if $found == nil
          		return(false)
          	end
          	
          	$logger.debug("Hypervisor installation successful.".green.bold)
          	return true
   end
# ======================================================================================
#
#               /$$      /$$  /$$$$$$  /$$$$$$ /$$   /$$
#              | $$$    /$$$ /$$__  $$|_  $$_/| $$$ | $$
#              | $$$$  /$$$$| $$  \ $$  | $$  | $$$$| $$
#              | $$ $$/$$ $$| $$$$$$$$  | $$  | $$ $$ $$
#              | $$  $$$| $$| $$__  $$  | $$  | $$  $$$$
#              | $$\  $ | $$| $$  | $$  | $$  | $$\  $$$
#              | $$ \/  | $$| $$  | $$ /$$$$$$| $$ \  $$
#              |__/     |__/|__/  |__/|______/|__/  \__/ 
# ======================================================================================

  def Installer.main
    
      $logger.debug( "Installer main ...")
      
      # get my IP address
      ip = open('http://whatismyip.akamai.com').read
    
      results = Geocoder.search(ip)
      puts results.first.coordinates.to_s.green.bold
      puts results.first.country.green.bold
      puts
        
      # manifest list of files to download. [installer, ova]
      windowsx64_manifest = '{"install":"VirtualBox-6.0.8-r130520-MultiArch_amd64.msi", "ova": "NodeHavenUbuntu.zip", "certs":["oracle-1.cer","oracle-2.cer"]}'
      windowsx86_manifest = '{"install":"VirtualBox-6.0.8-r130520-MultiArch_x86.msi", "ova": "NodeHavenUbuntu.zip", "certs":["oracle-1.cer","oracle-2.cer"]}'
      linux_manifest = '{"install":"virtualbox-6.0_6.0.8-130520_Ubuntu_bionic_amd64.deb", "ova":"NodeHavenUbuntu.zip"}'  
    
      if OS.windows?()
        $logger.debug("Windows host...")
        
        # get System Information
        getSystemInfoCsv
        
        m = isWindowsx64 ? windowsx64_manifest : windowsx86_manifest
        
        install_success = false
        if virtualBoxExists == false
        	install_success = install_files_on_windows(JSON.parse(m))
        else
          $logger.debug("Hypervisor already installed!".yellow.bold)
          $logger.debug("deployment over existing Hypervisor not supported yet.".yellow.bold)
          $logger.debug("please delete your current Hypervisor before running install again.".yellow.bold)
        end
        	
      end
        
      puts "bye".cyan.bold
      return install_success
  end
  
  end
end
  