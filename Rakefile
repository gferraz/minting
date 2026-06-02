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

Rake::TestTask.new('bench') do |t|
  t.libs = %w[lib test]
  t.pattern = 'test/performance/*_benchmark.rb'
end

Rake::TestTask.new('bench:parse') do |t|
  t.libs = %w[lib test]
  t.pattern = 'test/performance/parse_benchmark.rb'
  t.ruby_opts << '-r test_helper.rb'
end

Rake::TestTask.new('bench:edge') do |t|
  t.libs = %w[lib test]
  t.pattern = 'test/performance/algorithm_benchmark.rb'
  t.ruby_opts << '-r test_helper.rb'
end

Rake::TestTask.new('bench:regression') do |t|
  t.libs = %w[lib test]
  t.pattern = 'test/performance/regression_benchmark.rb'
  t.ruby_opts << '-r test_helper.rb'
end

Rake::TestTask.new('bench:competitive') do |t|
  t.libs = %w[lib test]
  t.pattern = 'test/performance/competitive_performance_benchmark.rb'
  t.ruby_opts << '-r test_helper.rb'
end

RuboCop::RakeTask.new(:cop)

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
  t.options = ['-o doc/api'] # Place the documentos in doc/api
  t.stats_options = ['--list-undoc']
end

task default: :test
