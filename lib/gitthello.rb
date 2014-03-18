require_relative 'gitthello/models/configuration'
require_relative 'gitthello/models/github_helper'
require_relative 'gitthello/models/trello_helper'
require_relative 'gitthello/models/board'
require_relative 'gitthello/sync'

module Gitthello
  extend self

  def configuration
    @configuration ||= Configuration.new
  end
end
