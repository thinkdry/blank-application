fixtures = Array.new

# Fixtures predecedence
# => Load all items before assigning them workspaces (items table)
fixtures |= ['videos', 'publications', 'images', 'artic_files', 'articles', 'audios', 'items']
# => Load users because inserting random number of comments for each user
fixtures |= ['users', 'comments']

# Add missing fixtures (all yml files in test/fixtures folder)
Pathname.new(File.join(RAILS_ROOT, 'test', 'fixtures')).each_entry do |file|
  if (file.extname == '.yml')
    fixture_name = file.basename('.yml').to_s
    fixtures << fixture_name unless fixtures.include?(fixture_name)
  end
end

ENV['FIXTURES'] = fixtures.join(',')
