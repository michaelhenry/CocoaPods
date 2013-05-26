module Pod
  
  class Command
  
    class Config < Command
      CONFIG_FILE_PATH = File.expand_path('~/.config/cocoapods')

      self.summary = ''
      self.description = <<-DESC
      DESC

      self.arguments = '[name] [path]'

      def initialize(argv)
        @local = argv.flag?('local')
        @global = argv.flag?('global')
        @name   = argv.shift_argument
        @path   = argv.shift_argument
        super
      end
      def self.options
        [['--local' ,'sergserg'], ['--global', 'sergresgse']].concat(super)
      end
      
      def run
        FileUtils.touch(CONFIG_FILE_PATH) unless File.exists? CONFIG_FILE_PATH
        
        config = YAML.load(File.open(CONFIG_FILE_PATH)) || {}
        config[@name] ||= {}
        config[@name][scope] = @path
        
        File.open(CONFIG_FILE_PATH, 'w') { |f| f.write(YAML.dump(config)) }
      end

      private

      def scope
        @global ? 'global' : 'local'
      end
    end

  end
end
