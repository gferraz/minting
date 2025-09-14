$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

begin
  require 'simplecov'
  SimpleCov.coverage_dir 'tmp/simplecov'
  SimpleCov.start
rescue LoadError
  puts 'SimpleCov not available - skipping coverage'
end

begin
  require 'minitest/autorun'
  require 'minitest/benchmark'
  Minitest.after_run {}
rescue LoadError
  puts 'Minitest not available - using basic test framework'
end

require 'minting'
