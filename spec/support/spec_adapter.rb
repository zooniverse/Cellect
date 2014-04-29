require 'oj'

class SpecAdapter < Cellect::Adapters::Default
  def project_list
    fixtures.keys
  end
  
  def load_project(name)
    data = fixtures[name]
    project_for(name, data).load_data data.fetch('entries', [])
  end
  
  # def load_user(id)
  #   # TO-DO
  # end
  
  def fixtures
    @fixtures ||= { }.tap do |fixtures|
      Dir["#{ _fixture_path }/*.json"].collect do |f|
        name = File.basename(f).sub /\.json$/, ''
        data = Oj.strict_load File.read f
        fixtures[name] = data
      end
    end
  end
  
  protected
  
  def _path_of(project_name)
    File.join(_fixture_path, "#{ project_name }.json")
  end
  
  def _fixture_path
    File.expand_path File.join(__FILE__, '../../fixtures/project_data')
  end
end
