require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rake/testtask'
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
 # t.pattern = 'test/performance/**/*_benchmark.rb'
end

Rake::TestTask.new('bench:competitive') do |t|
  t.libs = %w[lib test]
  t.pattern = 'test/performance/competitive/*_benchmark.rb'
  #t.ruby_opts << '-r test_helper.rb'
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
  t.pattern = 'test/performance/competitive_performance_benchmark.rb'
end

RuboCop::RakeTask.new(:cop)

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
  t.options = ['-o doc/api'] # Place the documentos in doc/api
  t.stats_options = ['--list-undoc']
end

task default: :test
