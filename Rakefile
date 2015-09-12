#!/usr/bin/env rake

CWD = ENV['PWD']
ENV['TASKDATA'] = "#{CWD}/t/tasks"
ENV['TASKRC'] = "#{CWD}/t/taskrc"

task :dump do
  sh 'vim --version'
end

task :clean do
  rm_rf '.vim-flavor'
end

task :install do
  sh 'bundle install'
  sh 'bundle exec vim-flavor install'
end

task :compile do
  sh 'bundle exec vim-flavor test t/dummy_spec.vim'
  Dir.chdir(".vim-flavor/deps/Shougo_vimproc.vim") do
    sh 'make'
  end
end

task :reset do
  sh "git checkout #{ENV['TASKDATA']}"
  sh "git checkout #{ENV['TASKRC']}"
end

task :test do
  sh 'bundle exec vim-flavor test t/taskwarrior/*_spec.vim t/taskwarrior/**/*_spec.vim'
end

task :ci => [:dump, :test]

task :default => [:test]
