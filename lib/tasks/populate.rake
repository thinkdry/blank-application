namespace :db do
  desc "Load Test Data"
	task :populate => :environment do
    require 'file_path_utils'
    require 'faker'
    require 'populator'
    [Article,Image].each(&:delete_all)
    ['article','image'].each do |item|
      item = item.classify.constantize
      item.populate 1000 do |ele|
        ele.title = Populator.words(1..3).titleize
        ele.description = Populator.words(3..5)
        ele.user_id = User.find(rand(2) + 1)
        ele.comments_number = rand(100)
        ele.rates_average = rand(5).to_f
        ele.viewed_number = rand(100)
        ele.created_at = 2.years.ago..Time.now
        if item.to_s == 'Article'
          ele.body = Populator.sentences(2..10)
        end
      end
    end
    Article.all.each do |a|
      a.associated_workspaces = ['1','2']
      a.save
    end
    Image.all.each do |i|
      i.associated_workspaces = ['1','2']
      i.image_file_name = file_path_import(:model => 'image', :id => i.id, :file_name => 'image.png')
      i.image_content_type = 'image/png'
      i.image_file_size = 215640
      i.image_updated_at =  Time.now
      i.save
    end
  end
end
