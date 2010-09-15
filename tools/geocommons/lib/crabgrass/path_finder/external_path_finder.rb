require File.dirname(__FILE__) + '/../external_api'

module Crabgrass
  class ExternalPathFinder

     def self.find(page_type,path)
       Crabgrass::ExternalAPI.for(page_type).call(:find, convert(page_type,path))
     end

     # takes a crabgrass ParsedPath Object, and maps it on a external api
     def self.convert(page_type,path)
       api = Crabgrass::ExternalAPI.for(page_type)
       spec = api.map_table
       key_value_seperator = api.key_value_separator
       argument_separator = api.argument_separator
       ret = ""
       # "tag/pakistan"
       path.keywords.each do |keyword|
         if spec[keyword]
           # -> tag
           ret << spec[keyword]
           # -> tag
           ret << key_value_separator         # TODO behaviour for more than one argument per keyword
                                              # use the new keywords_with_args - method to do this
           # tag:
           ret << path.args_for(keyword)    # tags:[pakistan,maharachi]  || tag:pakistan,tag:maharachi
           # tag:pakistan
           ret << argument_separator
           #tag:pakistan
         end
       end
       ret.chop! if ret.last == argument_separator # NOTE argument separator may only be one character
       ret # the new path
       # output for geocommons s.th. like:
       # :query => "fdsfsdfs"
       # :query => "tag:dfsdfsd"
     end
   end
end
