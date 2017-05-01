$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'

SimpleCov.coverage_dir('tmp/reports')
SimpleCov.start

require 'minting'

require 'minitest/autorun'
require 'minitest/benchmark'

Minitest.after_run {}
