require 'fileutils'

this_dir   = File.dirname(__FILE__)
asset_dir  = this_dir + '/lib'
root_dir   = this_dir + '/../../..'
helper_dir = root_dir + '/app/helpers'

FileUtils.cp(asset_dir + '/yacaph_helper.rb', helper_dir)
