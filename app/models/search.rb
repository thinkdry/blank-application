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


class Search < ActiveRecord::Base
  # Tableless model
  def self.columns() @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

	serialize :conditions, Hash
	
	column :category, :string

	column :models, :string

  # Text plain search
   
	column :full_text_field, :text_area

  # Advanced search

	column :conditions, :string
	column :created_before, :date
	column :created_after, :date

	# Filter

	column :filter_name, :string
	column :filter_way, :string
	column :filter_limit, :integer

  # Validation
  validates_date :created_after, :created_before, :allow_nil => true

  # Models for acts_as_xapian Search
	def models= params
		self[:models] = params.join(',')
	end


	def get_value_of_param(param_name)
		return self[:conditions][param_name]
	end

  # Build Conditions for Advance Search, checking paramerters passed
	def conditions
		res = []
		if self[:conditions]
			self[:conditions].each do |k, v|
				res << ["#{k} == #{v}"]
			end
		end
		res << ["created_at < '#{self[:created_before].to_date}'"] if self[:created_before]
		res << ["created_at > '#{self[:created_after].to_date}'"] if self[:created_after]
		#raise res.join(' AND ').inspect
		return res.join(' AND ')
	end

  # Search on Single, Multiple Models with filters according to Passed Parameters
	def do_search
		results = []
		if self[:models].split(',').size == 1
			# Research on ONE model
			model_const = self[:models].split(',').first.classify.constantize
			if !self[:full_text_field].blank? && (self[:full_text_field] != I18n.t('layout.search.search_label'))
				results += model_const.full_text_with_xapian(self[:full_text_field]).advanced_on_fields(self.conditions).filtering_with(self[:filter_name], self[:filter_way], self[:filter_limit])
			else
				results += model_const.advanced_on_fields(self.conditions).filtering_with(self[:filter_name], self[:filter_way], self[:filter_limit])
			end
		else
			# Research on VARIOUS models
			self[:models].split(',').each do |model_name|
				model_const = model_name.classify.constantize
				if !self[:full_text_field].blank? && (self[:full_text_field] != I18n.t('layout.search.search_label'))
					results += model_const.full_text_with_xapian(self[:full_text_field]).advanced_on_fields(self.conditions)
				else
					results += model_const.advanced_on_fields(self.conditions)
				end
				# Filer in Ruby, not top, need to find a MySQL way
				#raise results.inspect
				if self[:filter_name] != 'weight'
					results = results.sort do |x, y|
						if (self[:filter_way] == 'desc')
							x.send(self[:filter_name].to_sym) <=> y.send(self[:filter_name].to_sym)
						else
							y.send(self[:filter_name].to_sym) <=> x.send(self[:filter_name].to_sym)
						end
					end # TODO limit
				end
			end
		end
		return results
	end

end
