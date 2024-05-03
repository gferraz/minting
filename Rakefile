require 'bundler/gem_tasks'
require 'rubocop/rake_task'
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

task default: :test
