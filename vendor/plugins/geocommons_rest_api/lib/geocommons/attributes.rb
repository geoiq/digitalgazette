# Common attribute functionality.
#
# Example:
#
#   class FooBar
#     attributes :foo, :bar
#   end
#
# will define for you:
# * FooBar#foo
# * FooBar#foo=
# * FooBar#bar
# * FooBar#bar=
#
# Also, initializing those is as easy as:
#
#   FooBar.new(:foo => 'x', :bar => 'y', :a => 'b')
#
# This will set @foo and @bar, but discard @a, as it is not a valid attribute.
#
module Geocommons::Attributes
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def attributes(*attrs)
      if (attrs = attrs.flatten).any?
        (@attributes = attrs.map(&:to_sym)).each do |attribute|
          attr(attribute.to_sym, true)
        end
      else
        unless @attributes.any?
          raise "You need to define attributes in #{self.name}"
        end
        @attributes
      end
    end
  end

  def initialize(params={})
    (params.keys.map(&:to_sym) & self.class.attributes).each do |key|
      value = params[key] || params[key.to_s]
      # log_debug { "Loading attribute: #{key} = #{value}" }
      instance_variable_set("@#{key}", value)
    end
  end

  private

  def log_debug(msg=nil, &block)
    Rails.logger.debug do
      "[Geocommons::Attributes] #{msg || block.call}"
    end
  end
end
