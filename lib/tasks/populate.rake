namespace :db do
  desc "Load Test Data"
	task :populate => :environment do
    require 'file_path_utils'
    require 'faker'
    require 'populator'

    # Set the count a records to load
    count = ENV['COUNT'] ? ENV['COUNT'].to_i : 10
    ITEMS.each{|i| i.classify.constantize.delete_all}
    ITEMS.each do |item|
      item = item.classify.constantize
      item.populate count do |ele|
        ele.title = Populator.words(1..3).titleize
        ele.description = Populator.words(3..5)
        ele.user_id = User.find(rand(2) + 1)
        ele.comments_number = rand(100)
        ele.rates_average = rand(5).to_f
        ele.viewed_number = rand(100)
        ele.created_at = 2.years.ago..Time.now
        if item.to_s == 'Article' || item.to_s == 'Newsletter'
          ele.body = Populator.paragraphs(1..3)
        end
        if item.to_s == 'FeedSource'
          ele.url == Faker::Internet.domain_name
        end
        if item.to_s == 'Bookmark'
          ele.link == Faker::Internet.domain_name
        end
      end
    end

    (User.all - ([User.find(1)] + [User.find(2)])).each{|u| u.delete}
    User.populate count do |user|
      user.firstname = Faker::Name.first_name
      user.login = user.firstname.downcase
      user.lastname = Faker::Name.last_name
      user.email = Faker::Internet.email
      user.system_role_id = 3
      user.address = Faker::Address.street_name
      user.company = Faker::Company.name
      user.phone = Faker::PhoneNumber.phone_number
      user.nationality = Faker::Address.uk_country
      user.salt = '356a192b7913b04c54574d18c28d46e6395428ab'
      user.crypted_password = 'a2c297302eb67e8f981a0f9bfae0e45e4d0e4317'
    end

    (Workspace.all - ([Workspace.find(1)] + [Workspace.find(2)])).each{|ws| ws.delete}
    Workspace.populate count do |ws|
      ws.title = Populator.words(1..3).titleize
      ws.description = Populator.sentences(1..3).titleize
      ids = []
      User.find(:all,:select => :id).each{|u| ids.push(u.id) }
      ws.creator_id = ids.rand
      ws.created_at = 2.years.ago..Time.now
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

    Audio.all.each do |i|
      i.associated_workspaces = ['1','2']
      i.audio_file_name = file_path_import(:model => 'audio', :id => i.id, :file_name => 'audio.mp3')
      i.audio_content_type = 'audio/mpeg'
      i.audio_file_size = 98423
      i.state = 'encoded'
      i.audio_updated_at =  Time.now
      i.save
    end

    Video.all.each do |i|
      i.associated_workspaces = ['1','2']
      i.video_file_name = file_path_import(:model => 'video', :id => i.id, :file_name => 'video.flv')
      i.video_content_type = 'video/mpeg'
      i.state = 'encoded'
      i.video_file_size = 590296
      i.video_updated_at =  Time.now
      i.save
    end

    CmsFile.all.each do |i|
      i.associated_workspaces = ['1','2']
      i.cmsfile_file_name = file_path_import(:model => 'cmsfile', :id => i.id, :file_name => 'blank.pdf')
      i.cmsfile_content_type = 'image/png'
      i.cmsfile_file_size = 215640
      i.cmsfile_updated_at =  Time.now
      i.save
    end

  end
end

