# == Schema Information
# Schema version: 20181126085723
#
# Table name: searches
#
#  category        :string
#  models          :string
#  full_text_field :text
#  conditions      :string
#  created_before  :date
#  created_after   :date
#  filter_name     :string
#  filter_way      :string
#  filter_limit    :integer
#

# This object manage the research on the Blank application.
# It is actally tableless. TODO Save search params
#
# The Search object is waiting for various parameters allowing it to request the database,
# and the order the results.
#
class Search < ActiveRecord::Base

	# Tableless model
  def self.columns() @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

	serialize :conditions, Hash
	serialize :pagination, Hash
	serialize :filter, Hash
	#serialize :workspace_ids, Array

	column :category, :string
	column :models, :string
	column :user_id, :integer
	column :permission, :string
	column :full_text, :text_area
	column :conditions, :string

	column :created_before, :date
	column :created_after, :date

	column :filter, :string
	column :pagination, :string

  # Validation
  validates_date :created_after, :created_before, :allow_nil => true

  # Models for acts_as_xapian Search
	def models= params
		self[:models] = params.join(',')
	end


	def get_value_of_param(param_name)#:nodoc:
		return self[:conditions][param_name]
	end

  # Build Conditions for Advance Search, checking paramerters passed
#	def conditions
#		res = []
#		if self[:conditions]
#			self[:conditions].each do |k, v|
#				res << ["#{k} == #{v}"]
#			end
#		end
#		res << ["created_at < '#{self[:created_before].to_date}'"] if self[:created_before]
#		res << ["created_at > '#{self[:created_after].to_date}'"] if self[:created_after]
#		#raise res.join(' AND ').inspect
#		return res.join(' AND ')
#	end

	def workspace_ids= p
		self[:workspace_ids] = p ? p.join(',') : nil
	end

	def workspace_ids
		self[:workspace_ids] ? self[:workspace_ids].split(',') : nil
	end
	
	def param
		return {
			:user_id => self.user_id,
			:permission => self.permission,
			#:category => self.category,
			#:models => self.models,
			:workspace_ids => self.workspace_ids,
			:full_text => self.full_text,
			:conditions => self.conditions,
			:filter => self.filter,
			:pagination => self.pagination
		}
	end

  # Search on Single, Multiple Models with filters according to Passed Parameters
	def do_search
		results = []
		if self[:models].split(',').size == 1
			# Research on ONE model
			model_const = self[:models].split(',').first.classify.constantize
			results = model_const.get_da_objects_list(self.param)
		else
			# Research on VARIOUS models
			# TODO use MySQL view, but permissions ...
			self[:models].split(',').each do |model_name|
				model_const = model_name.classify.constantize
				results += model_const.get_da_objects_list(self.param)
			end
			results = results.paginate(:per_page => self[:pagination][:per_page].to_i, :page => self[:pagination][:page].to_i, :order => self[:filter][:field]+' '+self[:filter][:way])
		end
		return results
	end

end
