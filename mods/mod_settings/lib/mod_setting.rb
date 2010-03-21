class ModSetting
  class << self
    include Enumerable

    def register(opts)
      @settings_by_name ||= { }
      return if @settings_by_name[opts[:name]]
      setting = new(opts)
      @settings ||= []
      @settings.push(setting)
      @settings_by_name[setting.name] = setting
    end

    def each(&block)
      @settings.each(&block)
    end
  end

  TYPES = [:integer, :string, :text, :boolean, :enumerable]

  attr :mod
  attr :name
  attr :label
  attr :description
  attr :type
  attr :options

  TYPES.each do |type|
    define_method("#{type}?") do
      self.type == type
    end
  end

  def initialize(opts={})
    opts.each_pair { |k, v| instance_variable_set("@#{k}", v) }
    validate!
    setup_enumerable if enumerable?
  end

  def select_options
    i = 0 ; options.map { |opt| [i+=1, opt] }
  end

  def validate!
    [:mod, :name, :label, :type].each do |opt|
      raise ArgumentError.new("Missing option: #{opt}") unless instance_variable_get("@#{opt}")
    end
    @type = @type.to_sym
    raise ArgumentError.new("Invalid type: #{@type} - valid types are: #{TYPES.inspect}") unless TYPES.include?(@type)
    raise ArgumentError.new("You need to provide options when defining a enumerable") if @type == :enumerable && !@options
    # FIXME: figure out how to do this test without breaking "script/generate plugin_migration"
    #raise "Sites don't have a '#{name}' column! Did you create the migration and migrate the database? " unless Site.column_names.include?(name.to_s)
  end

  def setup_enumerable
    Site.instance_eval %Q{
      def #{name}
        enum_options_for_#{name}[self.#{name}]
      end
    }
    Site.send(:attr_reader, "enum_options_for_#{name}")
    Site.instance_variable_set("@enum_options_for_#{name}", options)
  end

  # TODO: allow multiple options for enumerables
  def multiple
    false
  end
end
