module Crabgrass
  # NOTE: I am not really sure, if we need External Pathfinder
  # Theoretically all our external models already provide find methods
  #
  # But the idea was this: The 'normal' pathfinder, allowes to have a human readable path
  # and split it into pieces, we can create a query from
  #
  # For every external resource we will have an own style to build the query
  #
  # so instead calling the finders with their needed paramaters on their own,
  # we convert the internal path into one of the externals.
  #
  # This should be done by a specification for every external model, that, at best, would be hosted online
  #
  #
  class ExternalPathFinder

    def self.find(page_type,path,options={})
      Crabgrass::ExternalAPI.for(page_type).call(:find, convert(page_type,path).merge(options)) #FIXME options handling not implemented in Geocommons::RestAPI::FinderMethods#find, see ::Pagination#paginate # NOTE we do not use find in DG at this time
    end

    def self.paginate(page_type,path,options={})
      Crabgrass::ExternalAPI.for(page_type).call(:paginate, convert(page_type,path).merge(options))
    end

    # takes a crabgrass ParsedPath Object, and maps it on a external api
    #

    # TODO this is too hardcoded
    def self.convert(page_type,path,options={ })
      api = Crabgrass::ExternalAPI.for(page_type)
      spec = api.map_table
      query_builder = spec[:query_builder]
      query_builder[:keywords].each_pair.inject({ }) do |params, (cg_key, external_key)|
        key_value = { }
        # Process keywords
        if path.keywords.include?(cg_key)
          if external_key.kind_of?(Proc)
            if cg_key.kind_of?(Proc)
              # lambda {|path|} => (lambda {} #=> { key => value, ... })
              args = cg_key.call(path)
              key_value = external_key.call(args)
            else
              # '...' => (lambda {} #=> value)
              key_value[cg_key] = external_key.call(path.arg_for(cg_key))
            end
          else
            if cg_key.kind_of?(Proc)
              # (lambda {|path|} #=> key) => '...'
              cg_key.call(path)
            else
              # '...' => '...'
              key_value[external_key.to_sym] = path.arg_for(cg_key)
            end
          end
        elsif options.keys.include?(cg_key.to_sym)
          key_value[external_key.to_sym] = options[cg_key.to_sym]
        end
        params.merge(key_value)
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
