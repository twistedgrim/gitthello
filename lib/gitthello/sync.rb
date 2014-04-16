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

    def synchronize_only_board(board_name)
      # because the trello API is a bit flaky, brute-force retry this
      # if API throws an error.
      repeatthis do
        @boards.select { |a| a.name == board_name }.map(&:synchronize)
      end
    end

    def add_trello_link_to_issues
      @boards.map(&:add_trello_link_to_issues)
    end

    private

    def repeatthis(cnt=5,&block)
      last_exception = nil
      cnt.times do
        begin
          return yield
        rescue Exception => e
          last_exception = e
          sleep 0.1
          next
        end
      end
      raise last_exception
    end

  end
end
