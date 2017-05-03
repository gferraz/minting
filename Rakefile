require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rubycritic/rake_task'
require 'rake/testtask'

CLOBBER.include %w[tmp]

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
  t.ruby_opts << '-rtest_helper.rb'
end

Rake::TestTask.new(:bench) do |t|
  t.libs = %w[lib test]
  t.pattern = 'test/**/*_benchmark.rb'
end

RuboCop::RakeTask.new(:cop)

RubyCritic::RakeTask.new do |task|
  # Name of RubyCritic task. Defaults to :rubycritic.
  task.name    = 'critic'

  # Glob pattern to match source files. Defaults to FileList['.'].
  task.paths   = FileList['lib/**/*.rb']

  # You can pass all the options here in that are shown by "rubycritic -h" except for
  # "-p / --path" since that is set separately. Defaults to ''.
  # task.options = '--mode-ci --format json'

  # Defaults to false
  # task.verbose = true
end
task default: :test
