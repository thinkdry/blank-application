#!/usr/local/bin/ruby -w
require 'rubygems'
require 'digest/sha1'

module Yacaph

   EligibleChars = 'abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ'
   ABitOfSalt    = '#%%/steqi98f48*&8.@".duhe7y7'
   
   DefaultParameters = {
      :image_width    => 260,
      :image_height   => 50,
      :captcha_length => 5
   }
   
   def self.encrypt_string(filename)
      # Gerenate the filename based on the string
      # TODO: change the salt to something random for your site.
      Digest::SHA1.hexdigest("#{ABitOfSalt}#{filename.gsub(/ /,'').downcase}")
   end
   
   def self.generateCaptchaImage(params = {})
      
      params = DefaultParameters.dup.merge(params)
      
      text_img  = Magick::Image.new(params[:image_width], params[:image_height])
      black_img = Magick::Image.new(params[:image_width], params[:image_height]) do
         self.background_color = 'black'
      end
      
      # Generate a 5 character random string
      random_string = (1..params[:captcha_length]).collect { EligibleChars[rand(EligibleChars.size), 1] }.join(' ')
      
      # Gerenate the filename based on the string where we have removed the spaces
      # TODO: change the salt to something random for your site.
      filename = encrypt_string(random_string) + '.png'
      
      # Render the text in the image
      text_img.annotate(Magick::Draw.new, 0,0,0,3, random_string) {
             self.gravity = Magick::CenterGravity
             self.font_family = 'times'
             self.font_weight = Magick::BoldWeight
             self.fill = '#666666'
             self.stroke = 'black'
             self.stroke_width = 2
             self.pointsize = 44
          }

      # Apply a little blur and fuzzing
      text_img = text_img.gaussian_blur(1.2, 1.2).sketch(20, 30.0, 30.0).wave(7, 90)

      # Now we need to get the white out
      text_mask = text_img.negate
      text_mask.matte = false

      # Add cut-out our captcha from the black image with varying tranparency
      black_img.composite!(text_mask, Magick::CenterGravity, Magick::CopyOpacityCompositeOp)

      # Write the file to disk
      puts 'Writing image file ' + filename
      black_img.write(filename) # { self.depth = 8 }
      
      # Collect rmagick
      GC.start
   end
end