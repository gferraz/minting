# frozen_string_literal: true

module Mint
  extend self

  # Loads currencies from YAML file into the registry.
  #
  # @param registry [Hash] the registry hash to populate
  # @return [Hash] the populated registry
  # @api private
  def world_currencies
    @world_currencies ||= begin
      path = File.join(File.expand_path('../data', __dir__), 'currencies.yaml')

      YAML.load_file(path).each_with_object({}) do |entry, registry|
        registry[entry['code']] = Currency.new(**entry.transform_keys(&:to_sym))
      end
    end.freeze
  end
end
