class SimpleSpecControllerGenerator < Rails::Generator::NamedBase

  def initialize(runtime_args, runtime_options = {})
    super    
  end

  def manifest
    record do |m|
      # Test directories.
      m.directory(File.join('spec/controllers', class_path))
      m.template('controller_spec.rb', File.join('spec/controllers', class_path, "#{file_name}_spec.rb"))
    end
  end

  protected
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} simple_spec_controller [ControllerName]"
    end
    
    def actual_controller_name
      class_name.underscore.downcase
    end

    def controller_name 
      class_name.demodulize
    end
end
