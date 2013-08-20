require File.expand_path('../../../spec_helper', __FILE__)
require 'yaml'

module Pod
  describe Command::Config do
    extend SpecHelper::TemporaryRepos

    LOCAL_REPOS = 'LOCAL_REPOS'
    GLOBAL_REPOS = 'GLOBAL_REPOS'
    pod_name = 'ObjectiveSugar'
    pod_path = '~/code/OSS/ObjectiveSugar'
    project_name = 'SampleProject'
    #project_path = '~/path/to/example'
    #scopes       = ['global', 'local']

    before do
      Config.instance = nil
      def Dir.pwd; '~/code/OSS/SampleProject'; end

      @config_file_path = temporary_directory + "mock_config"
      Command::Config.send(:remove_const, 'CONFIG_FILE_PATH')
      Command::Config.const_set("CONFIG_FILE_PATH", @config_file_path)
    end

    it "writes local repos for each project" do
      run_command('config', "--local", pod_name, pod_path)
      yaml = YAML.load(File.open(@config_file_path))

      yaml[LOCAL_REPOS][project_name][pod_name].should.equal pod_path
    end

    it "writes global repos without specifying project" do
      run_command('config', "--global", pod_name, pod_path)
      yaml = YAML.load(File.open(@config_file_path))

      yaml[GLOBAL_REPOS][pod_name].should.equal pod_path
    end

      #it "deletes a #{scope} configuration option from the config file" do
        #not_current_scope = scopes.detect { |s| s != scope }

        #run_command('config', "--#{not_current_scope}", project_name, project_path)
        #run_command('config', "--#{scope}", project_name, project_path)
        #run_command('config', "--#{scope}", "--delete", project_name)

        #yaml = YAML.load(File.open(@config_file_path))
        #yaml[project_name][scope].should.equal nil
        #yaml[project_name][not_current_scope].should.equal project_path
      #end

      #it "deletes the config key if no scopes are set" do
        #run_command('config', "--#{scope}", project_name, project_path)
        #run_command('config', "--#{scope}", "--delete", project_name)

        #yaml = YAML.load(File.open(@config_file_path))
        #yaml[project_name].should.equal nil
      #end

    #it "defaults to local scope" do
      #run_command('config', pod_name, pod_path)
      #yaml = YAML.load(File.open(@config_file_path))

      #yaml[LOCAL_REPOS][project_name].should.equal project_path   
      #yaml[GLOBAL_REPOS][project_name].should.equal nil
    #end


    it "raises help! if invalid args are provided" do
      [
        lambda { run_command("config", 'ObjectiveSugar') },
        lambda { run_command("config", "--local", 'ObjectiveSugar') },
        lambda { run_command("config", "--global", 'ObjectiveSugar') },
        lambda { run_command("config", '~/code/OSS/ObjectiveSugar') },
      ]
      .each { |invalid| invalid.should.raise CLAide::Help }
    end
  end
end

# ===================
# Config file format
# ===================
#
# ---
# LOCAL_REPOS:
#   SampleApp:
#     ARAnalytics: ~/code/ARAnalytics
# 
# GLOBAL_REPOS:
#   ObjectiveRecord: ~/code/OSS/ObjectiveRecord
#   ObjectiveSugar: ~/code/OSS/ObjectiveSugar
# 
