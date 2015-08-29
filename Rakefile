#!/usr/bin/env rake

CWD = ENV['PWD']
ENV['TASKDATA'] = "#{CWD}/t/tasks"
ENV['TASKRC'] = "#{CWD}/t/taskrc"

task :dump do
  sh 'vim --version'
end

task :install do
  sh 'bundle install'
  sh 'bundle exec vim-flavor install'
  Dir.chdir("#{ENV['HOME']}/.vim/flavors/Shougo_vimproc.vim") do
    sh 'make'
  end
end

task :reset do
  sh "git checkout #{ENV['TASKDATA']}"
end

task :test do
  sh 'bundle exec vim-flavor test t/**/*_spec.vim'
end

task :ci => [:dump, :test]

task :default => [:test]
