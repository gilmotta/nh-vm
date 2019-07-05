#!/usr//bin/env ruby

=begin
  Version 1.0.0
=end

  require 'colorize'
  require 'aws-sdk-s3'
  require 'open-uri'
  require 'speedtest'
  require_relative 'os_detector.rb'

  module NODE_HAVEN
    module Downloader
    # ================= Globals
    $access = 'AKIAU453DS3K36KI34LO'
    $secret = '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'
    
    $s3_path = 'https://nh-storage.s3.amazonaws.com/'
   
    # ==================================================================================
    #
    # ==================================================================================
    
    def s3_download filename
  
      starting = Time.now
      puts "downloading #{filename}".green.bold
      
      # download using S3 API
      s3 = Aws::S3::Resource.new(region: 'us-east-1', credentials: Aws::Credentials.new($access, $secret))
      
      # Create the object to retrieve
      obj = s3.bucket('nh-storage').object(filename)
      
      # Get the item's content and save it to a file
      obj.get(response_target: './' + filename)
      
      # time consuming operation
      ending = Time.now
      elapsed = ending - starting
      elapsed = elapsed/60 # in minutes
      
      puts "#{filename} downloaded in ".cyan.bold + elapsed.to_s + " minutes\n\n"
  
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
    def main
      
      @logger = Logger.new(STDOUT)
      #@logger.level = Logger::WARN
      @logger.level = Logger::DEBUG
      
      # manifest list of files to download. [installer, ova]
      #windows_manifest = '{"installer":"VirtualBox-6.0.8-130520-Win.exe", "ova": "NodeHavenUbuntu.zip"}'
      #linux_manifest = '{"installer":"virtualbox-6.0_6.0.8-130520_Ubuntu_bionic_amd64.deb", "ova":"NodeHavenUbuntu.zip"}'
      windowsx64_manifest = '{"install":"VirtualBox-6.0.8-r130520-MultiArch_amd64.msi", "ova": "NodeHavenUbuntu.zip", "certs":["oracle-1.cer","oracle-2.cer"]}'
      windowsx86_manifest = '{"install":"VirtualBox-6.0.8-r130520-MultiArch_x86.msi", "ova": "NodeHavenUbuntu.zip", "certs":["oracle-1.cer","oracle-2.cer"]}'
      linux_manifest = '{"install":"virtualbox-6.0_6.0.8-130520_Ubuntu_bionic_amd64.deb", "ova":"NodeHavenUbuntu.zip"}'
        
      puts "Hello Inspector!\n\n".cyan.bold
      puts "speed test...\n".cyan.bold
      
      test = Speedtest::Test.new(
        download_runs: 2,
          upload_runs: 2,
          ping_runs: 2,
          download_sizes: [750, 1500],
          upload_sizes: [10000, 400000],
          debug: true
       )
          
       results = test.run
       puts results   
       
      if OS.windows?
        # setup windows files here
        print "Windows ".green.bold
        if OS.windows_x64?
          windows_manifest = windowsx64_manifest
          print "x64\n".green.bold
        else
          windows_manifest = windowsx86_manifest
          print "x86\n".green.bold
        end
        
        manifest = windows_manifest
        
      else
        if OS.linux?
          # setup linux files here
          puts "Linux".green.bold
          
          linux = OS.linux_variant
          
          if linux[:distro] == "Ubuntu"
            puts "Ubuntu detected, install will proceed...".green.bold
            manifest = linux_manifest
          else
            puts "This Linux distro is not support yet.".yellow.bold
          end
          
        else
          if OS.mac?
            puts "Sorry MAC is not supported at this time.\n Support for Windows and Ubuntu hosts only\n".red.bold
          else
            puts "Unknown OS not supported.\n Support for Windows and Ubuntu hosts only\n".red.bold
          end
          
        end
        
      end
       
       jsonmanifest = JSON.parse(manifest)      
    
       if 1 == 1  # used to debug
         
           # =============================================================================
           # =============================================================================
           # .MSI or .EXE file
         
           filename = jsonmanifest["install"]
          
          if 1 == 1
        
            s3_download filename
            
          end
            
          # ========================================================================
          # ========================================================================
          # OVA file  
          
          #filename = 'NodeHavenUbuntu.zip'
          filename = jsonmanifest["ova"]
          
          if 1 == 1
                   
            s3_download filename
            
          end
          
          if 1 == 1 
            
            jsonmanifest['certs'].each do |certname|
              @logger.debug( certname.green.bold + " found.")
              s3_download certname
            end
            
          end  
        end
    
      end
    end
  end
  
  if 1 == 1  
    include NODE_HAVEN
    include OS
    include Downloader   
    Downloader.main
  end