require 'rubygems'
require 'will_paginate'
require 'net/http'
require 'json'


# WillPaginate::Collection.create(page, per_page, total_entries) do |pager|
#   count_options = options.except(:page, :per_page, :total_entries, :finder)
#   find_options = count_options.except(:count).update(:offset => pager.offset, :limit => pager.per_page)

#   args << find_options.symbolize_keys # else we may break something
#   found = execute(*args, &block)
#   pager.total_entries = found[:total]
#   found = found[:docs]
#   pager.replace found
# end

module Geocommons
  def self.config=(config)
    @config = HashWithIndifferentAccess.new(config)
  end

  def self.config(*path)
    raise "Geocommons.config not set!" unless @config
    parts = []
    path.inject(@config) do |config, part|
      parts << part
      raise "Geocommons config path not found: #{parts.inspect}" unless config[part]
      next(config[part])
    end
  end
end
