module Crabgrass
  class ExternalPathFinder

    def self.find(page_type,path,options={})
      Crabgrass::ExternalAPI.for(page_type).call(:find, convert(page_type,path)) #FIXME options handling not implemented in Geocommons::RestAPI::FinderMethods#find, see ::Pagination#paginate
    end

    def self.paginate(page_type,path,options={})
      Crabgrass::ExternalAPI.for(page_type).call(:paginate, convert(page_type,path))
    end
    
    # takes a crabgrass ParsedPath Object, and maps it on a external api
    def self.convert(page_type,path)
      api = Crabgrass::ExternalAPI.for(page_type)
      spec = api.map_table
      query_builder = spec[:query_builder]
      query_builder[:keywords].each_pair.inject({ }) do |params, (cg_key, external_key)|
        if path.keywords.include?(cg_key)
          params.merge(external_key => path.arg_for(cg_key))
        else
          params
        end
      end

      # FIXME: this has been the original functionality, where you can map things from a to b
      # it's not necessary for DG and we had the problem, that GC expects a hash
      # instead of creating the ability to specify, that the result should be a hash and how it should look,
      # we did this small hack above
      #
      # TODO try something like .inject(return_structure) do ...
      
      # key_value_separator = api.key_value_separator
      # argument_separator = api.argument_separator
      # ret = ""
      # # "tag/pakistan"
      # path.each do |element|
      #   if query_builder[:keywords][element[0]] &&  path.keywords.include?(element[0])
      #     # -> tag
      #     ret << query_builder[:keywords][element[0]]
      #     # -> tag
      #     ret << key_value_separator         # TODO behaviour for more than one argument per keyword
      #     # use the new keywords_with_args - method to do this
      #     # tag:
      #     ret << element[1]    # tags:[pakistan,maharachi]  || tag:pakistan,tag:maharachi
      #     # tag:pakistan
      #     ret << argument_separator
      #     #tag:pakistan
      #   end
      # end
      # #debugger
      # ret.chop! if ret.last == argument_separator # NOTE argument separator may only be one character
      # ret # the new path
      # # output for geocommons s.th. like:
      # # :query => "fdsfsdfs"
      # # :query => "tag:dfsdfsd"
    end



  end
end
