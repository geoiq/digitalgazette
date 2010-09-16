module Crabgrass
  class ExternalPathFinder

    def self.find(page_type,path)
      Crabgrass::ExternalAPI.for(page_type).call(:find, convert(page_type,path))
    end
x
    # takes a crabgrass ParsedPath Object, and maps it on a external api
    def self.convert(page_type,path)
      api = Crabgrass::ExternalAPI.for(page_type)
      spec = api.map_table
      query_builder = spec[:query_builder]
      key_value_separator = api.key_value_separator
      argument_separator = api.argument_separator
      ret = ""
      # "tag/pakistan"
      #debugger
      path.each do |element|
        if query_builder[:keywords][element[0]] &&  path.keywords.include?(element[0])
          # -> tag
          ret << query_builder[:keywords][element[0]]
          # -> tag
          ret << key_value_separator         # TODO behaviour for more than one argument per keyword
          # use the new keywords_with_args - method to do this
          # tag:
          ret << element[1]    # tags:[pakistan,maharachi]  || tag:pakistan,tag:maharachi
          # tag:pakistan
          ret << argument_separator
          #tag:pakistan
        end
      end
      #debugger
      ret.chop! if ret.last == argument_separator # NOTE argument separator may only be one character
      ret # the new path
      # output for geocommons s.th. like:
      # :query => "fdsfsdfs"
      # :query => "tag:dfsdfsd"
    end



  end
end
