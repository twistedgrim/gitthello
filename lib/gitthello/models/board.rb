module Gitthello
  class Board
    def initialize(board_config)
      @config = board_config.clone
      @github_helper = GithubHelper.new(Gitthello.configuration.github.token,
                                        @config.repo_for_new_cards,
                                        @config.repos_to_consider)
      @trello_helper = TrelloHelper.new(Gitthello.configuration.trello.token,
                                        Gitthello.configuration.trello.dev_key,
                                        @config.name)
    end

    def doit
      puts "==> Handling Board: #{@config.name}"
      @trello_helper.setup
      @trello_helper.close_issues(@github_helper)
      @trello_helper.move_cards_with_closed_issue(@github_helper)
      @github_helper.retrieve_issues
      @github_helper.new_issues_to_trello(@trello_helper)
      @trello_helper.new_cards_to_github(@github_helper)
    end
  end
end