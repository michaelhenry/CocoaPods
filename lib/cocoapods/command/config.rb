module Pod

  class Command

    # This command was made in first place for supporting local repos.
    # Command uses file ~/.config/cocoapods
    #
    # Sample usage: 
    #   pod config --local ObjectiveSugar ~/code/OSS/ObjectiveSugar
    #   pod config --global ObjectiveRecord ~/code/OSS/ObjectiveRecord
    #
    #   pod config --delete --local Kiwi
    #   pod config --delete --global Kiwi
    #
    class Config < Command
      CONFIG_FILE_PATH = File.expand_path('~/.config/cocoapods')

      self.summary = 'Something like `bundle config` ... but better.'
      self.description = <<-DESC
        Run `bundle help config`, but replace 'bundle' with 'pod'
      DESC

      self.arguments = '[name] (path) [--local, --global, --delete]'

      def initialize(argv)
        @local = argv.flag?('local')
        @global = argv.flag?('global')
        @should_delete = argv.flag?('delete')
        @name   = argv.shift_argument
        @path   = argv.shift_argument
        super
      end
      def self.options
        [['--local' ,'sergserg'], ['--global', 'sergresgse'], ['--delete', 'meh']]
      end

      def run
        help! unless args_are_valid?

        config = load_config
        config[@name] ||= {}
        if @should_delete
          config[@name].delete(scope)
          config.delete(@name) if config[@name].empty?
        else
          config[@name][scope] = @path
        end

        File.open(CONFIG_FILE_PATH, 'w') { |f| f.write(YAML.dump(config)) }
      end

      private

      def scope
        @global ? 'global' : 'local'
      end

      def load_config
        FileUtils.touch(CONFIG_FILE_PATH) unless File.exists? CONFIG_FILE_PATH
        YAML.load(File.open(CONFIG_FILE_PATH)) || {}
      end

      def args_are_valid?
        valid = !!@name
        valid &= !!@path unless @should_delete
        valid
      end

    end

  end
end
