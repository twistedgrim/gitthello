desc "Synchronize Github and Trello"
task :sync do
  Gitthello::Sync.new.synchronize
end

desc "Link issues to cards if the issue don't already have a link."
task :link_issues_to_cards do
  Gitthello::Sync.new.add_trello_link_to_issues
end
