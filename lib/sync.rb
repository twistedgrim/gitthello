module Gitthello
  class Sync
    def initialize
      @github = GithubHelper.new
      @trello = TrelloHelper.new
    end

    def doit
      @trello.setup
      @trello.close_issues(@github)
      @trello.move_cards_with_closed_issue(@github)
      @github.retrieve_issues
      new_issues_to_trello
      new_cards_to_github
    end

    private

    def new_cards_to_github
      @trello.all_cards_not_at_github.each do |card|
        issue = @github.
          open_issue(card.name,
                     card.desc + "\n\n\n[Added by trello](#{card.url})")
        card.add_attachment(issue.html_url, "github")
      end
    end

    def new_issues_to_trello
      @github.issue_bucket.each do |repo_name, issue|
        next if @trello.has_card?(issue)
        prefix = repo_name.sub(/^mops./,'').capitalize
        c = Trello::Card.create( :name => "%s: %s" % [prefix,issue["title"]],
                                 :list_id => @trello.list_todo.id,
                                 :desc => issue["body"])
        c.add_attachment(issue["html_url"], "github")
      end

      @github.backlog_bucket.each do |repo_name, issue|
        next if @trello.has_card?(issue)
        prefix = repo_name.sub(/^mops./,'').capitalize
        c = Trello::Card.create( :name => "%s: %s" % [prefix,issue["title"]],
                                 :list_id => @trello.list_backlog.id,
                                 :desc => issue["body"])
        c.add_attachment(issue["html_url"], "github")
      end
    end
  end
end
