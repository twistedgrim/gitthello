require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require "sinatra/multi_route"
require 'json'

require 'github_api'
require 'trello'
require 'dotenv'

require_relative 'lib/gitthello'

set :static, true

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

get '/issues/*' do
  content_type :json

  @config = Gitthello.configuration

  @github = Github.new(:oauth_token => @config.github.token)

  is_configed_repo = (@config.boards.map do |_,board_config|
                        Gitthello::Board.new(board_config)
                      end.map(&:repo_for_new_cards).
                      include?(params[:splat].first))
  if is_configed_repo
    owner,repo = params[:splat].first.split(/\//)
    { :value => @github.issues.list(:user => owner, :repo => repo,
                                    :state => "open" ).count }
  else
    { :value => 0 }
  end.to_json
end

get '/lists/:board_name' do
  content_type :json

  @config = Gitthello.configuration

  Trello.configure do |cfg|
    cfg.member_token         = @config.trello.token
    cfg.developer_public_key = @config.trello.dev_key
  end

  is_configed_board = (@config.boards.map do |_,board_config|
                         Gitthello::Board.new(board_config)
                       end.map(&:name).
                       include?(params[:board_name]))

  if is_configed_board
    brd = Trello::Board.all.select { |b| b.name == params[:board_name] }.first
    { :value => brd.lists.count }
  else
    { :value => 0 }
  end.to_json
end
