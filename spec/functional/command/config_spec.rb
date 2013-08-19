require File.expand_path('../../../spec_helper', __FILE__)
require 'yaml'

module Pod
  describe Command::Config do
    extend SpecHelper::TemporaryRepos

    project_name = 'example'
    project_path = '/path/to/example'
    scopes       = ['global', 'local']

    before do
      Config.instance = nil
      @file_path = temporary_directory + "mock_config"
      Command::Config.send(:remove_const, 'CONFIG_FILE_PATH')
      Command::Config.const_set("CONFIG_FILE_PATH", @file_path)
    end

    scopes.each do |scope|
      it "writes a #{scope} configuration option to the config file" do
        run_command("config", "--#{scope}", project_name, 'old_path')
        run_command('config', "--#{scope}", project_name, project_path)
        yaml = YAML.load(File.open(@file_path))
        yaml[project_name][scope].should.equal project_path
      end

      it "deletes a #{scope} configuration option from the config file" do
        not_current_scope = scopes.detect { |s| s != scope }

        run_command('config', "--#{not_current_scope}", project_name, project_path)
        run_command('config', "--#{scope}", project_name, project_path)
        run_command('config', "--#{scope}", "--delete", project_name)

        yaml = YAML.load(File.open(@file_path))
        yaml[project_name][scope].should.equal nil
        yaml[project_name][not_current_scope].should.equal project_path
      end

      it "deletes the config key if no scopes are set" do
        run_command('config', "--#{scope}", project_name, project_path)
        run_command('config', "--#{scope}", "--delete", project_name)

        yaml = YAML.load(File.open(@file_path))
        yaml[project_name].should.equal nil
      end

      it "raises help! if invalid args are provided" do
        lambda { run_command("config", "--#{scope}", 'old_path') }
          .should.raise CLAide::Help
      end
    end

    it "defaults to local scope" do
      run_command('config', project_name, project_path)
      yaml = YAML.load(File.open(@file_path))
      yaml[project_name]['local'].should.equal project_path   
      yaml[project_name]['global'].should.equal nil
    end

  end
end

# DESIRED FORMAT
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
