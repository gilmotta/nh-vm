#!/usr//bin/env ruby

=begin
  Version 1.0.0
=end

  require 'colorize'
  require 'aws-sdk-s3'
  require 'open-uri'
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
      
      if File.file?(filename) == false      
          # download using S3 API
          s3 = Aws::S3::Resource.new(region: 'us-east-1', credentials: Aws::Credentials.new($access, $secret))
          
          # Create the object to retrieve
          obj = s3.bucket('nh-storage').object(filename)
          
          # Get the item's content and save it to a file
          obj.get(response_target: './' + filename)
      else
        $logger.debug( "file already exists #{filename}.")
      end
      
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
    def Downloader.main
      
      $logger.debug( "Downloader main ...")
      
      # manifest list of files to download. [installer, ova]
      #windows_manifest = '{"installer":"VirtualBox-6.0.8-130520-Win.exe", "ova": "NodeHavenUbuntu.zip"}'
      #linux_manifest = '{"installer":"virtualbox-6.0_6.0.8-130520_Ubuntu_bionic_amd64.deb", "ova":"NodeHavenUbuntu.zip"}'
      windowsx64_manifest = '{"install":["VirtualBox-6.0.8-r130520-MultiArch_amd64.msi"],"cab": ["common.cab"], "ext":["Oracle_VM_VirtualBox_Extension_Pack-6.0.8.vbox-extpack"],"ova": ["NodeHavenUbuntu.zip"], "certs":["oracle-1.cer","oracle-2.cer"]}'
      windowsx86_manifest = '{"install":["VirtualBox-6.0.8-r130520-MultiArch_x86.msi"],"cab": ["common.cab"], "ext":["Oracle_VM_VirtualBox_Extension_Pack-6.0.8.vbox-extpack"], "ova": ["NodeHavenUbuntu.zip"], "certs":["oracle-1.cer","oracle-2.cer"]}'
      linux_manifest = '{"install":"virtualbox-6.0_6.0.8-130520_Ubuntu_bionic_amd64.deb", "ova":"NodeHavenUbuntu.zip"}'   
       
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
          if 1 == 1

            jsonmanifest['install'].each do |filename|
              $logger.debug( filename.green.bold + " found.")
              s3_download filename
            end
            
          end
          
           # =============================================================================
           # =============================================================================
           # cab files are required by windows, in Linux this will not be necessary        
          if 1 == 1
            jsonmanifest['cab'].each do |filename|
              $logger.debug( filename.green.bold + " found.")
              s3_download filename
            end
          end
                      
           # =============================================================================
           # =============================================================================
           # ext pack files        
          if 1 == 1
            jsonmanifest['ext'].each do |filename|
              $logger.debug( filename.green.bold + " found.")
              s3_download filename
            end
          end
        
          # ========================================================================
          # ========================================================================
          # OVA file            
          if 1 == 1        
            jsonmanifest['ova'].each do |filename|
              $logger.debug( filename.green.bold + " found.")
              s3_download filename
            end
          end
          
         # ========================================================================
         # ========================================================================
         # Cert file                     
          if 1 == 1 
            
            jsonmanifest['certs'].each do |certname|
              $logger.debug( certname.green.bold + " found.")
              s3_download certname
            end
            
          end  
        end
    
      end
    end
  end
  
  # debug code for stand alone run
  if 0 == 1  
    include NODE_HAVEN
    include OS
    include Downloader
    $logger.debug("Attention: Debug is enabled!".yellow.bold)   
    Downloader.main
  end