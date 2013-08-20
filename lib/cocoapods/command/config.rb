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
      LOCAL_REPOS = 'LOCAL_REPOS'
      GLOBAL_REPOS = 'GLOBAL_REPOS'

      self.summary = 'Something like `bundle config` ... but better.'
      self.description = <<-DESC
        Run `bundle help config`, but replace 'bundle' with 'pod'
      DESC

      self.arguments = '[pod name] (path) [--local, --global, --delete]'

      def initialize(argv)
        @local = argv.flag?('local')
        @global = argv.flag?('global')
        @should_delete = argv.flag?('delete')
        @pod_name   = argv.shift_argument
        @pod_path   = argv.shift_argument
        super
      end

      def self.options
        [['--local' , 'Uses the local pod for the current project only'],
         ['--global', 'Uses the local pod everywhere'],
         ['--delete', 'Removes the local pod from configuration']]
      end

      def run
        help! unless args_are_valid?
        store_config
      end

      private

      def scope
        @global ? 'global' : 'local'
      end

      def load_config
        FileUtils.touch(CONFIG_FILE_PATH) unless File.exists? CONFIG_FILE_PATH
        YAML.load(File.open(CONFIG_FILE_PATH)) || fresh_config
      end

      def fresh_config
        { GLOBAL_REPOS => {}, LOCAL_REPOS => {} }
      end

      def args_are_valid?
        valid = !!@pod_name
        valid &= !!@pod_path unless @should_delete
        valid
      end

      def store_config
        config = load_config
        #if @should_delete
          #config[@pod_name].delete(scope)
          #config.delete(@pod_name) if config[@pod_name].empty?
        #else
        if @global
          config[GLOBAL_REPOS][@pod_name] = @pod_path
        else
          config[LOCAL_REPOS][@project_name] ||= {}
          config[LOCAL_REPOS][@project_name][@pod_name] = @pod_path
        end
        #end

        File.write(CONFIG_FILE_PATH, YAML.dump(config))
      end

    end

  end
end
