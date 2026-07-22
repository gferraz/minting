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

    # Preload world currencies from YAML file during module load.
    path = File.join(File.expand_path('../../data', __dir__), 'world-currencies.yaml')
    @world_currencies = YAML.load_file(path).to_h { |entry| [entry['code'], Currency.new(**entry.transform_keys(&:to_sym))] }.freeze
    @currencies = @world_currencies.dup.freeze

    # Loads ISO world currencies from YAML file.
    #
    # @return [Hash{String => Currency}] ISO-4217 world currencies mapped by code
    # @api private
    def self.world_currencies =  @world_currencies

    # Returns the frozen hash of all registered currencies (world + custom).
    #
    # @return [Hash{String => Currency}] registered currencies mapped by code
    # @api private
    def self.currencies = @currencies
  end
end
