if File.exist?(config_path = File.join(Rails.root, 'config', 'geocommons.yml'))
  Dispatcher.to_prepare do
    Geocommons.config = YAML.load_file(config_path)
  end
end
