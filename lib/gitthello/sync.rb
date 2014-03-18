module Gitthello
  class Sync
    def initialize
      @boards = Gitthello.configuration.boards.map do |_,board_config|
        Gitthello::Board.new(board_config)
      end
    end

    def doit
      @boards.map(&:doit)
    end
  end
end
