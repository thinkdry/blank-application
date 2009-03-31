$:.unshift "#{File.dirname(__FILE__)}/../lib"

require 'RMagick' 
require 'yacaph'

namespace :yacaph do

   desc 'Generate a set of captcha images off-line'
   task :generate => [:create_dir] do 
      Dir.chdir('public/images/captcha') do
         image_count = ENV['COUNT'].to_i || 3
         puts "Generating #{image_count} captcha images off-line"
         for i in 1..image_count 
            Yacaph::generateCaptchaImage
         end
      end
   end
   
   desc 'Create a directory to hold the captcha images'
   task :create_dir do
      begin
         Dir.chdir('public/images/captcha') do 
         end
      rescue
         Dir.mkdir('public/images/captcha')
         puts 'Created directory to hold captcha images'
      end
   end
end