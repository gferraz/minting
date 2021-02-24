$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'simplecov'

SimpleCov.coverage_dir 'tmp/simplecov'
SimpleCov.start

require 'minting'

require 'minitest/autorun'
require 'minitest/benchmark'

Minitest.after_run {}
