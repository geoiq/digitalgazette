require File.dirname(__FILE__) + '/../../../test/test_helper'

class TestModel < Object

  def initialize(options={ })
    options.each_pair do |k,v|
      instance_variable_set("@#{k}", v)
    end
  end
  
  def self.paginate(*args)
    options = args.last if args.last.kind_of?(Hash)
    unless options
      raise "Pagination needs options"
    end
    ret = []
    options[:per_page].times do
      ret << new({ :name => "somename"}) #OPTIMIZE write a cooler mock class
    end
    ret
  end
  
  def self.find(*args)
    ret = []
    30.times do
      ret << TestModel.new({ :name => "somename"}) #OPTIMIZE write a cooler mock class
    end
    ret
  end


end
