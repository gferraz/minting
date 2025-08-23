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

# Performance benchmark tasks
Rake::TestTask.new('bench:performance') do |t|
  t.libs = %w[lib test]
  t.pattern = 'test/performance/*_benchmark.rb'
  t.ruby_opts << '-r test_helper.rb'
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

task 'bench:all' => ['bench', 'bench:performance']

RuboCop::RakeTask.new(:cop)

task default: :test
