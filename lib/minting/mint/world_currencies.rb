# frozen_string_literal: true

module Mint
  module_function

  # Loads ISO world currencies from YAML file into the registry.
  #
  # @return [Hash{String => Currency}] ISO-4217 world currencies mapped by code
  # @api private
  def world_currencies
    @world_currencies ||= begin
      path = File.join(File.expand_path('../data', __dir__), 'currencies.yaml')

      YAML.load_file(path).to_h { |entry| [entry['code'], Currency.new(**entry.transform_keys(&:to_sym))] }
    end.freeze
  end
end
