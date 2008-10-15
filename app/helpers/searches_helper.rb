module SearchesHelper
def page_entries_info(collection, options = {})
  entry_name = 'résultat'
  
  if collection.total_pages < 2
    case collection.size
    when 0; "Aucun #{entry_name}"
    when 1; "<b>1</b> #{entry_name}"
    else;   "Affichage des <b>#{collection.size}</b> #{entry_name.pluralize}"
    end
  else
    %{Affichage des #{entry_name.pluralize} <b>%d&nbsp;-&nbsp;%d</b> sur <b>%d</b> au total} % [
      collection.offset + 1,
      collection.offset + collection.length,
      collection.total_entries
    ]
  end
end
end