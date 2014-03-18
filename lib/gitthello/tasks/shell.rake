desc "Start a pry shell and load all gems"
task :shell do
  require 'pry'
  Pry.editor = "emacs"
  Pry.start
end

desc "The same as 'rails console' but for sinatra"
task :console => :shell
