white_space = FateSearch::Analysis::WhitespaceAnalyzer.new
analyzers = [white_space, white_space]
fragment = FateSearch::FragmentWriter.new(
  :path => "/tmp/index/fates/names-0000000", :analyzers => analyzers)
names = PersonName.find(:all)
names.each {|name| fragment.add(name.id, [name.given_name, name.family_name]) }
fragment.finish!