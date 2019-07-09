#!/usr//bin/env ruby

  require 'colorize'
  require_relative 'os_detector'
  require_relative 'version'
  require_relative 'geodecoder'
  require_relative 'downloader'
  require_relative 'installer'
  require_relative 'hostregistration'
  require_relative 'vmmanage'
  require_relative 'manifest'
  
  Dir["#{File.dirname(__FILE__)}/**/*.rb"].each { |f| puts 'require ' + f }

  include NODE_HAVEN
  include OS
  include Geodecoder
  include Downloader
  include Installer
  include Hostregistration
  include Manifest

  module NODE_HAVEN
    $logger = Logger.new(STDOUT)
    #$logger.level = Logger::WARN
    $logger.level = Logger::DEBUG
  end

  if OS.windows?
    system("cls")
  elsif OS.linux?
    system("clear")
  end
  
  puts "==================================".cyan.bold
  puts "=      VMmanizer version " + NODE_HAVEN::VERSION.cyan.bold
  puts "==================================".cyan.bold
  
  puts "This is going to take awhile, get some coffee and relax.\n".yellow.bold

  if OS.windows?
    # setup windows files here
    puts "Windows Host detected!".green.bold  
    puts "Discovering host location, capabilities and closest file server ...".green.bold
    Geodecoder.main   # move this call after Ubuntu also
    puts "Downloading files ...".green.bold
    Downloader.main   # download files from AWS
    puts "Installing Hypervisor ...".green.bold
    Installer.main    # install Hypervisor
    puts "Importing Node Haven VM ..."
    VMmanage.main    # install Hypervisor
    puts "Joining the Node Haven Federation ...".green.bold
    Hostregistration.main # register this host
    puts "\t\tWelcome to the Node Haven Federation !".green.bold
    puts "\t\tYour host just became a Jedi Apprentice.\n\t\tYou will rank up based on your host capabilities, reliability and consistency.".green.bold
    
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
  
  
  
