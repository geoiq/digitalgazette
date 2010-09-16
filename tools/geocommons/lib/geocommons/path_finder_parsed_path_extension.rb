module Geocommons
  module PathFinderParsedPathExtension
    # remove keyword
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
    def keywords_with_args options={ :ignore_atoms => true}
      inject({}) { |result,element|
        result[element.first] ||= []
        result[element.first] << all_args_for(element.first)
        result[element.first].uniq
      }
    end

  end
end
