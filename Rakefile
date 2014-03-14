# -*- coding: utf-8 -*-
require 'rubygems'
require 'bundler/setup'
require 'rake'
require 'rake/testtask'

require 'github_api'
require 'trello'
require 'dotenv'

Dotenv.load # load the .env file

Dir[File.join(File.dirname(__FILE__), 'lib', '*.rb')].each { |f| load f }
Dir[File.join(File.dirname(__FILE__), 'lib', 'tasks','*.rake')].each { |f| load f }

task :default => :test

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end
