require 'bundler/audit/task'
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'
require 'rubycritic/rake_task'
require 'yard'

CLOBBER.include %w[doc/css doc/js doc/Mint doc/*.html tmp .yardoc]

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
  t.ruby_opts << '-rtest_helper.rb'
end

Rake::TestTask.new('bench:all') do |t|
  t.libs = %w[lib test]
  t.pattern = 'test/performance/**/*_benchmark.rb'
end

Rake::TestTask.new('bench:core') do |t|
  t.libs = %w[lib test]
  t.pattern = 'test/performance/core/parse_benchmark.rb'
end

Rake::TestTask.new('bench:memory') do |t|
  t.libs = %w[lib test]
  t.pattern = 'test/performance/memory/*_benchmark.rb'
end

Rake::TestTask.new('bench:regression') do |t|
  t.libs = %w[lib test]
  t.pattern = 'test/performance/regression/*_benchmark.rb'
end

Rake::TestTask.new('bench:competitive') do |t|
  t.libs = %w[lib test]
  t.pattern = 'test/performance/competitive/**/*_benchmark.rb'
end

BASELINE_FILE = 'test/performance/check/results/baseline.json'

desc 'Run core benchmarks and update the baseline'
task 'bench:baseline' do
  sh "ruby test/performance/check/runner.rb #{BASELINE_FILE}"
  puts 'Baseline updated.'
end

desc 'Run core benchmarks and check for regressions against the baseline'
task 'bench:check' do
  ruby 'bin/bench_check'
end

Bundler::Audit::Task.new

RuboCop::RakeTask.new(:cop) do |task|
  task.patterns = ['lib']
end

RubyCritic::RakeTask.new do |task|
  task.name = 'critic'
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
  t.stats_options = ['--list-undoc']
end

task default: :test
