module Gitthello
  class GithubHelper
    attr_reader :issue_bucket, :backlog_bucket

    def initialize(oauth_token, repo_for_new_cards, repos_to_consider)
      @github            = Github.new(:oauth_token => oauth_token)
      @user, @repo       = repo_for_new_cards.split(/\//)
      @repos_to_consider = repos_to_consider
    end

    def create_issue(title, desc)
      @github.issues.
        create( :user => @user, :repo => @repo, :title => title, :body => desc)
    end

    def issue_closed?(user, repo, number)
      @github.issues.get(user,repo,number.to_i).state == "closed"
    end

    def close_issue(user, repo, number)
      @github.issues.edit(user, repo, number.to_i, :state => "closed")
    end

    def get_issue(user, repo, number)
      @github.issues.get(user, repo, number.to_i)
    end

    def retrieve_issues
      @issue_bucket, @backlog_bucket = [], []

      @repos_to_consider.split(/,/).map { |a| a.split(/\//)}.
        each do |repo_owner,repo_name|
        puts "Checking #{repo_owner}/#{repo_name}"
        repeatthis do
          @github.issues.
            list(:user => repo_owner, :repo => repo_name, :state => "open",
                 :per_page => 100).
            sort_by { |a| a.number.to_i }
        end.each do |issue|
          (if issue["labels"].any? { |a| a["name"] == "backlog" }
             @backlog_bucket
           else
             @issue_bucket
           end) << [repo_name,issue]
        end
      end

      puts "Found #{@issue_bucket.count} todos"
      puts "Found #{@backlog_bucket.count} backlog"
    end

    def new_issues_to_trello(trello_helper)
      issue_bucket.each do |repo_name, issue|
        next if trello_helper.has_card?(issue)
        prefix = repo_name.sub(/^mops./,'').capitalize
        trello_helper.create_todo_card("%s: %s" % [prefix,issue["title"]],
                                        issue["body"], issue["html_url"])
      end

      backlog_bucket.each do |repo_name, issue|
        next if trello_helper.has_card?(issue)
        prefix = repo_name.sub(/^mops./,'').capitalize
        trello_helper.create_backlog_card("%s: %s" % [prefix,issue["title"]],
                                          issue["body"], issue["html_url"])
      end
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
