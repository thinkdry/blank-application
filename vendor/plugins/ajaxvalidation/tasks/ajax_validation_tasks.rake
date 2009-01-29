require 'fileutils'

namespace :ajaxvalidation do
  desc "Copy configuration, js file and template to application"
  task :install do
    
    print "* Copy `ajax_validation.js` to `public/javascripts`... "
    FileUtils.cp(File.expand_path(File.dirname(__FILE__) + '/../public/javascripts/ajax_validation.js'),
                 File.expand_path(File.dirname(__FILE__) + '/../../../../public/javascripts/ajax_validation.js'))
    puts "OK"
    
    print "* Copy `custom_forms` template directory to `app/views`... "
    FileUtils.cp_r(File.expand_path(File.dirname(__FILE__) + '/../app/views/custom_forms'),
                   File.expand_path(File.dirname(__FILE__) + '/../../../../app/views'))
    puts "OK"
    
    print "* Copy configuration file (`custom_form.yml`) to config... "
    FileUtils.cp(File.expand_path(File.dirname(__FILE__) + '/../config/custom_form.yml'),
                 File.expand_path(File.dirname(__FILE__) + '/../../../../config/custom_form.yml'))
    puts "OK"
  end
end
