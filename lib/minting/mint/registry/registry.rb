# frozen_string_literal: true

require 'yaml'
require_relative 'symbols'
require_relative 'registration'
require_relative 'zeros'

# Mint registry: manages all cached state
module Mint
  # Internal registry for currencies, symbols, and zero-money cache.
  # All mutable shared state lives here.
  module Registry
    MUTEX = Monitor.new

    private_constant :MUTEX

    # Loads ISO world currencies from YAML file.
    #
    # @return [Hash{String => Currency}] ISO-4217 world currencies mapped by code
    # @api private
    def self.world_currencies
      @world_currencies || MUTEX.synchronize do
        @world_currencies = begin
          path = File.join(File.expand_path('../../data', __dir__), 'world-currencies.yaml')
          YAML.load_file(path).to_h { |entry| [entry['code'], Currency.new(**entry.transform_keys(&:to_sym))] }
        end.freeze
      end
    end

    # Returns the frozen hash of all registered currencies (world + custom).
    #
    # @return [Hash{String => Currency}] registered currencies mapped by code
    # @api private
    def self.currencies
      @currencies || MUTEX.synchronize { @currencies = world_currencies.dup.freeze }
    end
  end
end
