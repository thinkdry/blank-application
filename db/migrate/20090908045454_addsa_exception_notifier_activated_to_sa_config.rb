
class AddsaExceptionNotifierActivatedToSaConfig < ActiveRecord::Migration
  def self.up
    @configuration = get_sa_config
    if @configuration['sa_exception_notifier_activated'].nil?
      new_config = @configuration.merge!({'sa_exception_notifier_activated' => 'true'})
      @new=File.new("#{RAILS_ROOT}/config/customs/sa_config.yml", "w+")
      @new.syswrite(new_config.to_yaml)
    end
  end

  def self.down
    @configuration = get_sa_config
    @configuration.delete('sa_exception_notifier_activated')
    @new=File.new("#{RAILS_ROOT}/config/customs/sa_config.yml", "w+")
    @new.syswrite(@configuration.to_yaml)
  end

end
