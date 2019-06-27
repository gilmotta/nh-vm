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

  $systeminfocsv = nil  # system info results in CSV format
  $systeminfo = nil     # CSV object, serialized as an array $systeminfo["System Type"]
  
  def isWindowsx64
    $systeminfo["System Type"].include? "x64"
  end
  
  def getSystemInfoCsv      
      if OS.windows?()
          # if running on windows
          # get the system info in CSV format
          $systeminfocsv = `systeminfo /fo CSV`
      
          File.write('systeminfo.csv', $systeminfocsv)
          
          $systeminfo = CSV.read('systeminfo.csv', headers:true)   
      end          
  end
  
  def getSystemInfo
    
    resp_yaml = ""
    systeminfo = Array.new
    
    if OS.windows?()
      # if running on windows
      #resp_yaml = File.read("systeminfohalf.yaml")    # systeminfo
      
      #puts resp_yaml.yellow
      

      File.open("systeminfohalf.yaml").each do |resp_yaml|

            if resp_yaml != ""
              #systeminfo = YAML.load(resp_yaml)
              begin
                systeminfo << YAML.parse(resp_yaml)
              rescue Psych::SyntaxError
                puts "skip ln #{resp_yaml}".yellow.bold
              end
              if systeminfo != nil
                #puts "bit size #{systeminfo['System Type']}".green.bold
                #p systeminfo.inspect
              end
            end

      end
            
    end
    
    if systeminfo != nil
      #puts "bit size #{systeminfo["System Type"][0]}".green.bold
      #p systeminfo.inspect
      #p systeminfo.class
      systeminfo.each do |l|
        p l
        puts "===".blue
      end
    end
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

    path = ".\\vbox\\"
    unless File.file?(path + manifest["install"])
      @logger.debug( "\nInstaller #{manifest["install"]} not found. Failed to install hypervisor on host.\n")
      exit(false)
    end
    
    # ==== STEP 1 oracle certificates
    #
    # certutil -addstore "TrustedPublisher" oracle.cer
    
    # install all certificates required to run the VM
    manifest['certs'].each do |certname|
      @logger.debug( certname.green.bold + " found.")
      system("certutil -addstore \"TrustedPublisher\" " + certname)
    end
    
    # ==== STEP 2 .msi or .exe
    filename = manifest["install"]
    
    @logger.debug("Installing " + "#{manifest["install"]} ...".green.bold)
    
    starting = Time.now
   
    # ==== calling shell to install the hypervisor
    #
    # msiexec /I VirtualBox-2.1.4-42893-Win_amd64.msi /Passive /NoRestart
    system("msiexec /I #{manifest["install"]} /Passive /NoRestart")
    #
    # ====
    
    # time consuming operation
    ending = Time.now
    elapsed = ending - starting
    elapsed = elapsed/60 # in minutes
    
    @logger.debug("installation completed in #{elapsed} minutes")
    @logger.debug("file cleanup.")
    
    exit(true)
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

  puts "Hello Inspector!".cyan.bold
  puts "decoding our ip address".yellow.bold
  puts

  @logger = Logger.new(STDOUT)
  #@logger.level = Logger::WARN
  @logger.level = Logger::DEBUG

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
    @logger.debug("Windows host...")
    
    # get System Information
    getSystemInfoCsv
   
   m = isWindowsx64 ? windowsx64_manifest : windowsx86_manifest
   install_success = install_files_on_windows(JSON.parse(m))
     
  end
    
  puts "bye".cyan.bold