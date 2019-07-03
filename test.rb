#!/usr//bin/env ruby

  require 'colorize'
  require_relative 'os_detector'
  require_relative 'version'
  require_relative 'geodecoder'
  require_relative 'downloader'
  
  Dir["#{File.dirname(__FILE__)}/**/*.rb"].each { |f| puts 'require ' + f }

  include NODE_HAVEN
  include OS
  include Geodecoder
  include Downloader
  include Installer
  include Hostregistration
    
  puts "\n\nHello Inspector!".cyan.bold
  puts "version " + NODE_HAVEN::VERSION.cyan.bold
  
  if OS.windows?
    # setup windows files here
    puts "Windows Host detected!".green.bold
    
    puts "This is going to take awhile, get some coffee and relax."
    Geodecoder.main   # move this call after Ubuntu also
    Downloader.main   # download files from AWS
    Installer.main    # install Hypervisor
    Hostregistration.main # register this host
    
  else
    if OS.linux?
      # setup linux files here
      puts "Linux Host detected!".green.bold
      puts "support for Linux has been disabled temporarily!!!".red.bold
      
      linux = OS.linux_variant
      
      if linux[:distro] == "Ubuntu"
        #puts "Ubuntu detected, install will proceed...".green.bold
        puts "This Ubuntu is not support yet.".yellow.bold
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
  
  puts "bye".cyan.bold
  
  
  
