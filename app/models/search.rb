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
# Still under construction ... sorry for the mess.
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
  serialize :user, User
	#serialize :workspace_ids, Array

	column :category, :string
	column :models, :string
	column :user_id, :integer
	column :permission, :string
	column :full_text, :text_area
	column :conditions, :string

	column :created_at_before, :date
	column :created_at_after, :date

	column :filter, :string
	column :pagination, :string

  column :user, :string
  column :opti, :string
  # Validation
  validates_date :created_at_after, :created_at_before, :allow_nil => true

  # Models for acts_as_xapian Search
	def models= params
		self[:models] = params.join(',')
	end


	def get_value_of_param(param_name)#:nodoc:
		return self[:conditions][param_name]
	end

	def workspace_ids= p
		self[:workspace_ids] = p ? p.join(',') : nil
	end

	def workspace_ids
		self[:workspace_ids] ? self[:workspace_ids].split(',') : nil
	end
	
	def param
		return {
			:user => self.user,
			:permission => self.permission,
			#:category => self.category,
			#:models => self.models,
			:workspace_ids => self.workspace_ids,
			:full_text => self.full_text,
			:conditions => self.conditions,
			:filter => self.filter,
			:pagination => self.pagination,
			:opti => self.opti
		}
	end

  # Search on Single, Multiple Models with filters according to Passed Parameters
	def do_search
		results = []
		if self[:models].split(',').size == 1
			# Research on ONE model
			model_const = self[:models].split(',').first.classify.constantize
			results = model_const.get_da_objects_list(self.param)#.merge!({:skip_pag => true}))
		else
			# Research on VARIOUS models
			# TODO use MySQL view, but permissions ...
			self[:opti] ||= 'skip_full_pag'
			self[:models].split(',').each do |model_name|
				model_const = model_name.classify.constantize
				results += model_const.get_da_objects_list(self.param)
			end
			p "======================= #{self[:category]} ======== "+results.size.inspect
			# Sorting all the element in memory ... very costly actually
      results = results.sort_with_filter(self[:filter][:field], self[:filter][:way])
			# Paginating these sorted element
			results = results.paginate(:per_page => self[:pagination][:per_page].to_i, :page => self[:pagination][:page].to_i)
		end
		return results
	end

#  def advance_search_fields
#    if !self.conditions.nil?
#      self.created_at_before = self.conditions[:created_at_before]
#      self.created_at_after = self.conditions[:created_at_after]
#    end
#    return self
#  end
end
