module Geocommons
  module PathFinderParsedPathExtension
    
    
    #
    #
    # takes a hash with a keyword and values and adds them to the path
    def add_types! types
      types.each do |type|
        self << ["type",type.to_s]
      end
      self.sort
    end
 
    
    
    # Removes a keyword an all it's arguments completely
    #
    # You may want to use this method, when you
    # have extended the PathFinder
    #
    # and want to hide the existance of the keywords
    # from the rest of the code
    #
    # OPTIMIZE
    def remove_keyword name
      i = 0
      PathFinder::ParsedPath.new.replace(select { |e|
                                           i+=1 # index of next element
                                           ((e[0] != name) &&
                                            (!
                                             ((e[0] == "or") &&
                                              (self[i][0] == name))
                                             )
                                            )
                                         })
      # clean or conditions afterwards
    end

    
    # unless it may be expected args_for(keyword) does not
    # return all args
    #
    # this method gives you an array of all args for a
    # certain keyword
    #
    # it can be used like
    #
    # @path.tags when you say
    # @path.all_args_for('tag')
    #
    def all_args_for keyword
      select { |element|
        element[0] == keyword}.map { |element|
        element[1..-1]
      }.flatten.uniq
    end

    # pass :ignore_atoms => false if you want 'or' keywords
    #
    # atomare keywords are 'or' or things like 'imortant'
    # currently crabgrass is skipping most of these keywords
    # anyway using sphinx (see sphinx backend)
    #
    # if you want to implement such shourtcuts in a api
    #
    # you need to set ignore_atoms => false
    # and provide a proper mapping
    # for all of them
    def keywords options={ :ignore_atoms => true}
      map { |element|
        element[0] unless (options[:ignore_atoms] && PathFinder::ParsedPath::PATH_KEYWORDS[element[0]] == 0)
      }
    end

    # returns a hash with the keywords and all the args
    # pass :ignore_atoms => false if you want 'or' keywords
    # Note: You can use this, to convert a ParsedPath
    # into something like this:
    #
    # ['type',['wiki','asset']],['tag',['pakistan','peace']]
    def keywords_with_args options={ :ignore_atoms => true}
      inject({}) { |result,element|
        result[element.first] ||= []
        result[element.first] = all_args_for(element.first)
        result[element.first].uniq
        result
      }
    end

    def sort!
      self.sort{|a,b| (PathFinder::ParsedPath::PATH_ORDER[a[0]]||PathFinder::ParsedPath::PATH_ORDER['default']) <=> (PathFinder::ParsedPath::PATH_ORDER[b[0]]||PathFinder::ParsedPath::PATH_ORDER['default']) }
    end
    
  end
end
