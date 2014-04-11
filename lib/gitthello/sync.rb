module Gitthello
  class Sync
    def initialize
      @boards = Gitthello.configuration.boards.map do |_,board_config|
        Gitthello::Board.new(board_config)
      end
    end

    def synchronize
      @boards.map(&:synchronize)
    end

    def add_trello_link_to_issues
      @boards.map(&:add_trello_link_to_issues)
    end
  end
end
