ITEMS = ['article', 'image', 'cms_file', 'video', 'audio', 'publication', 'feed_source', 'bookmark']
LANGUAGES = ['en-US', 'fr-FR', 'es-ES']
FEED_ITEMS_IMPORTATION_TYPES = ['bookmark', 'publication']
WS_TYPES = ['closed', 'public', 'authorized', 'archived']
RIGHT_TYPES = ['system', 'workspace']
ITEM_CATEGORIES = ['cat1', 'cat2', 'cat3']

#require 'rake'
#require 'rake/testtask'
#require 'rake/rdoctask'
#require 'tasks/rails'
#Rake::Task["xapian:rebuild_index"].invoke("models='"+ITEMS.map{ |e| e.camelize}.join(' ')+"'")