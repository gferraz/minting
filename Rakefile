require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rake/testtask'
require 'yard'

CLOBBER.include %w[doc tmp .yardoc]

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
  t.ruby_opts << '-rtest_helper.rb'
end

Rake::TestTask.new(:bench) do |t|
  t.libs = %w[lib test]
  t.pattern = 'test/performance/*_benchmark.rb'
end

Rake::TestTask.new('bench:regression') do |t|
  t.libs = %w[lib test]
  t.pattern = 'test/performance/regression_benchmark.rb'
  t.ruby_opts << '-r test_helper.rb'
end

Rake::TestTask.new('bench:competitive') do |t|
  t.libs = %w[lib test]
  t.pattern = 'test/performance/competitive_benchmark.rb'
  t.ruby_opts << '-r test_helper.rb'
end

RuboCop::RakeTask.new(:cop)

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb'] # optional
  t.options = [] # optional
  t.stats_options = ['--list-undoc'] # optional
end

task default: :test
