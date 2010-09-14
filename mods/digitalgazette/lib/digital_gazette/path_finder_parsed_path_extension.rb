module DigitalGazette
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
  end
end
