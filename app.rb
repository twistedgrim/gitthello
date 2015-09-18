require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require "sinatra/multi_route"
require 'json'

require 'github_api'
require 'trello'
require 'dotenv'

require_relative 'lib/gitthello'

Dotenv.load

ENV['environment'] = ENV['RACK_ENV'] || 'development'

get '/' do
  @config = Gitthello.configuration

  @github = Github.new(:oauth_token => @config.github.token)

  @boards = @config.boards.map do |_,board_config|
    Gitthello::Board.new(board_config)
  end

  Trello.configure do |cfg|
    cfg.member_token         = @config.trello.token
    cfg.developer_public_key = @config.trello.dev_key
  end

  @github_usable = begin
                     !!@github.issues.list
                   rescue
                     false
                   end

  @trello_usable = begin
                     !!Trello::Board.all.count
                   rescue
                     false
                   end
  haml :index
end
