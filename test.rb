#!/usr//bin/env ruby

  require 'colorize'
  require_relative 'os_detector'

  puts 'Hello Inspector!'.cyan.bold
  
  if OS.windows?
    # setup windows files here
    puts "Windows".green.bold
    
  else
    if OS.linux?
      # setup linux files here
      puts "Linux".green.bold
      
      linux = OS.linux_variant
      
      if linux[:distro] == "Ubuntu"
        puts "Ubuntu detected, install will proceed...".green.bold
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
  
  
