require 'ostruct'

module Gitthello
  class Configuration
    attr_reader :boards, :trello, :github

    def initialize
      @trello = OpenStruct.new(:dev_key => ENV['TRELLO_DEV_KEY'],
                               :token => ENV['TRELLO_MEMBER_TOKEN'])
      @github = OpenStruct.new(:token => ENV['GITHUB_ACCESS_TOKEN'])

      # select BOARDS[xxx][yyy] from the environment and map them to hashes
      # i.e. @boards becomes '{ xxx => { yyy => val } }'
      @boards = Hash.new{|h,k|h[k]={}}
      ENV.keys.select { |a| a =~ /^BOARDS/ }.
        map { |keyname| keyname =~ /[^\[]*\[(\w*)\]\[(\w*)\]/ && [$1, $2] }.
        uniq.each do |subkey, attrname|
        @boards[subkey.downcase][attrname.downcase] =
          ENV["BOARDS[#{subkey}][#{attrname}]"]
      end
      @boards = Hash[@boards.map { |k,v| [k, OpenStruct.new(v)]}]
    end
  end
end
