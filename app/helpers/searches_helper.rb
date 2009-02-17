module SearchesHelper
def page_entries_info(collection, options = {})
  entry_name = I18n.t('layout.search.result')
  if collection.total_pages < 2
    case collection.size
    when 0; I18n.t('general.common_word.no1').capitalize+" #{entry_name}"
    when 1; "<b>1</b> #{entry_name}"
    else;   I18n.t('layout.search.displaying').capitalize+" <b>#{collection.size}</b> #{entry_name.pluralize}"
    end
  else
    %{#{I18n.t('layout.search.displaying').capitalize} #{entry_name.pluralize} <b>%d&nbsp;-&nbsp;%d</b> #{I18n.t('general.common_word.of')} <b>%d</b> #{I18n.t('general.common_word.found')}} % [
      collection.offset + 1,
      collection.offset + collection.length,
      collection.total_entries
    ]
  end
end
end