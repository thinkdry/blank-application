class AddSaConfigVariables < ActiveRecord::Migration
  def self.up
    Rake::Task['blank:create_sa_config'].invoke
  end

  def self.down
  end
end
