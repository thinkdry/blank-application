module TagsHelper
  def tag_list(tags)
    if tags.size > 0
      tags.collect { |t| t.name }.join(', ')
    else
      'aucun'
    end
  end
end