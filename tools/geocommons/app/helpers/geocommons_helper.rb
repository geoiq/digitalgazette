module GeocommonsHelper
  # returns an <iframe/> to embed the geocommons Maker, with the given path (e.g. /maps/new).
  def geocommons_maker_iframe(path, html_options={})
    content_tag(:iframe, '', html_options.merge(:src => File.join(Geocommons.config(:map, :maker), path)))
  end

  # returns all required <script/> tags to load a Geocommons map into the given +target+ (a DOM id)
  def geocommons_load_map(target, map_id)
    content_tag(:script, '', :charset => 'utf-8', :src => Geocommons.config(:map, :embed)) +
      content_tag(:script, %Q{
          Maker.maker_host = "#{Geocommons.config(:map, :maker)}";
          Maker.finder_host = "#{Geocommons.config(:map, :finder)}";
          Maker.core_host = "#{Geocommons.config(:map, :core)}";
          Maker.load_map("#{target}", #{map_id})
        }, :charset => 'utf-8')
  end
end
