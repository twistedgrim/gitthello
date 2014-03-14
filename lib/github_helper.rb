module Gitthello
  class GithubHelper
    attr_reader :issue_bucket, :backlog_bucket

    def initialize
      @github = Github.new(:oauth_token => ENV['GITHUB_ACCESS_TOKEN'])
    end

    def open_issue(title, desc)
      user, repo = ENV['GITHUB_REPO_FOR_NEW_CARDS'].split(/\//)
      @github.issues.
        create( :user => user, :repo => repo,
                :title => title, :body => desc)
    end

    def issue_closed?(user, repo, number)
      @github.issues.get(user,repo,number.to_i).state == "closed"
    end

    def close_issue(user, repo, number)
      @github.issues.edit(user, repo, number.to_i, :state => "closed")
    end

    def retrieve_issues
      @issue_bucket, @backlog_bucket = [], []

      ENV['GITHUB_REPOS'].split(/,/).map { |a| a.split(/\//)}.
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
