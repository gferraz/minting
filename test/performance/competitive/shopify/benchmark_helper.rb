# frozen_string_literal: true

# Require the money gem (used by shopify-money) BEFORE minting so it claims
# the top-level Money constant first. minting then warns-and-skips its
# auto-bind, leaving both classes intact for the competitive benchmark.
require_relative '../../benchmark_helper/shopify_setup'
require_relative '../../benchmark_helper'
