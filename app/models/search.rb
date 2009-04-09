# == Schema Information
# Schema version: 20181126085723
#
# Table name: searches
#
#  item_type_equals     :string
#  title_contains       :string
#  description_contains :string
#  user_name_contains   :string
#  created_after        :datetime
#  created_before       :datetime
#

class Search < ActiveRecord::Base
  # Tableless model
  def self.columns() @columns ||= []; end
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end
	
	column :category, :string
	column :models, :string
	# Text plain search
	column :full_text_field, :text_area
  # Advanced search
	column :conditions, :string
	# Filter
	column :filter_name, :string
	column :filter_way, :string
	column :filter_limit, :integer
  
#  validates_date :created_after, :created_before, :allow_nil => true

	def models= params
		self[:models] = params.join(',')
	end

	def conditions= params
		conditions = []
		params.each do |k, v|
			if !v.blank?
				conditions << "#{k} == #{(v.is_a?(Array) ? v.join(',') : v)}"
			end
		end
		self[:conditions] = conditions.join(' && ')
	end

	def conditions
		res = Hash.new
		if self[:conditions]
			self[:conditions].split(' && ').each do |e|
				tmp = e.split(' == ')
				res.merge!({ tmp.first => tmp.last })
			end
		end
		return res
	end

	def do_search
		results = []
		if self[:models].split(',').size == 1
			# Research on ONE model
			model_const = self[:models].split(',').first.classify.constantize
			if !self[:full_text_field].blank? && (self[:full_text_field] != I18n.t('layout.search.search_label'))
				results += model_const.full_text_with_xapian(self[:full_text_field]).advanced_on_fields(self.conditions).filtering_on_field(self[:filter_name], self[:filter_way], self[:filter_limit])
			else
				results += model_const.advanced_on_fields(self.conditions).filtering_on_field(self[:filter_name], self[:filter_way], self[:filter_limit])
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
				if self[:filter_name] != 'weight'
					results = results.sort do |x, y|
						if (self[:filter_way] == 'desc')
							x.send(self[:filter_name].to_sym) <=> y.send(self[:filter_name].to_sym)
						else
							y.send(self[:filter_name].to_sym) <=> x.send(self[:filter_name].to_sym)
						end
					end[0..self[:filter_limit].to_i] # TODO limit
				end
			end
		end
		return results
	end

end
