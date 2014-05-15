require 'oj'

class SpecAdapter < Cellect::Server::Adapters::Default
  def project_list
    fixtures.values
  end
  
  def load_data_for(project_name)
    fixtures.fetch(project_name, { }).fetch 'entries', []
  end
  
  def fixtures
    @fixtures ||= { }.tap do |fixtures|
      Dir["#{ _fixture_path }/project_data/*.json"].collect do |f|
        name = File.basename(f).sub /\.json$/, ''
        data = Oj.strict_load File.read f
        fixtures[name] = data
      end
    end
  end
  
  def user_fixtures
    @user_fixtures ||= { }.tap do |user_fixtures|
      Dir["#{ _fixture_path }/user_data/*.json"].sort.collect.with_index do |f, i|
        name = File.basename(f).sub /\.json$/, ''
        data = Oj.strict_load File.read f
        user_fixtures[name] = data
        user_fixtures[i + 1] = data
      end
    end
  end
  
  def load_user(project_name, id)
    user = user_fixtures[id]
    user ? user[project_name] : user_fixtures['new_user'][project_name]
  end
  
  protected
  
  def _fixture_path
    File.expand_path File.join(__FILE__, '../../fixtures')
  end
end
