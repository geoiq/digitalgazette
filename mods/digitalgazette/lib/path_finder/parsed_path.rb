class PathFinder::ParsedPath < Array

  def next(item)
    self[index(item)+1]
  end

  def previous(item)
    self[index(item)-1]
  end

  # remove keyword
  def remove_keyword name
    PathFinder::ParsedPath.new.replace(select{ |e| (e[0] != name) && (! (e[0] == "or" and self.next(e)[0] == name))})
    # clean or conditions afterwards
  end
end
