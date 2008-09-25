module ItemsHelper
  
  def self.included base
    define_prefixed_item_paths(base)
  end
  
  def item_show(parameters, &block)
    concat\
      render( :partial => "items/show",
              :locals => {  :object => parameters[:object],
                            :title => parameters[:title],
                            :block => block                 } ),
      block.binding
  end
  
  # Container of tags that include modal window. Contains the javascript events.
  # Please apply 'hidden' class on each child you want to be displayed on mouseover.
  def item_reactive_content_tag(tag, object, &block)
    concat \
      content_tag(tag,
        render(:partial => "items/hidden_window", :object => object) + capture(&block),
        :id           => "item_#{object.object_id}",
        :class        => 'item',
        :onmouseover  => 'this.addClassName("over")',
        :onmouseout   => 'this.removeClassName("over")',
        :onclick      => "window.location.href = '#{item_path(object)}'"),
      block.binding
  end
  
  # Render a lisf of recent items, recent comments and recent publications.
  # (Uses the `small_item_list` helper)
  def item_list
    items = [] # List being rendered
    
    # 1st: Collect items in workspaces
    conditions = [ "workspace_id IN (?)", current_workspace || current_user.all_workspaces ]
    items = Item.find(:all,
      :order => 'created_at DESC',
      :limit => 10,
      :conditions => conditions)
    items.collect! { |item| item.itemable }
    
    # 2nd: Include private item
    unless current_workspace
      [:images, :articles, :audios, :artic_files, :videos].each do |itemable_type|
        items |= current_user.send(itemable_type)
      end
    end
    
    # Sort by CREATED_AT DESC
    items.sort! {|a, b| b.created_at <=> a.created_at }
    
    render :partial => "items/list", :object => items[0..10]
  end
  
  # Item. Title and descriptions.
  # Modal window on mouseover, displaying additionnal informations
  def item_in_list(object, thumb = nil)
    render :partial => "items/item_in_list", :object => object
  end
  
  # Footer of each item form. Status, comments, tags...
  def item_status_fields(form, item)
    render :partial => "items/status", :locals => { :f => form, :item => item }
  end
  
  # Tag. Item's author is allowed to remove it by Ajax action.
  def item_tag tag, editable = false
    content = tag.name
    content += link_to_remote(image_tag('icons/delete.png'),
      :url => remove_tag_item_path(@current_object, :tag_id => tag.id),
      :loading => "$('ajax_loader').show()",
      :complete => "$('ajax_loader').hide()") if editable
    
    content_tag :span, content, :id => "tag_#{tag.id}"
  end
  
  def item_editable_tag tag
    item_tag tag, true
  end
  
  # Resourceful helper. May be used in generic forms (acts_as_item).
  def link_to_edit_item object
    link_to(
      image_tag('icons/pencil.png'),
      item_path(object)
    ) if permit?("edit of object", :object => object)
  end
  
  # Resourceful helper. May be used in generic forms (acts_as_item).
  def link_to_remove_item object
    link_to(
      image_tag('icons/delete.png'),
      item_path(object),
      :confirm => 'Êtes vous sur de vouloir supprimer cet élément ? Cette action est irréversible.',
      :method => :delete
    ) if permit?("delete of object", :object => object)
  end
  
  def item_path object, params = {}
    prefix = params.delete :prefix
    
    helper_name = String.new
    helper_name += prefix + '_' if prefix
    helper_name += 'workspace_' if current_workspace
    helper_name += object.class.to_s.underscore + '_path'
    
    args = [object, params]
    args.insert(0, current_workspace) if current_workspace

    send helper_name, *args
  end
  
  def new_item_path(model)
    helper_name = 'new_'
    helper_name += 'workspace_' if current_workspace
    helper_name += model.to_s.underscore + '_path'
    args = current_workspace ? [current_workspace] : []
    send(helper_name, *args)
  end
  
  def items_path(model)
    model = model.table_name unless model.is_a?(String)  
    if current_workspace
      workspace_content_url(current_workspace.id, :page => model)
    else
      content_url(:page => model)
    end
  end
  
  def display_tabs(page)
    html = '<ul id="tabs">'
    html += '<li '
    html += 'class="selected"' if (page=="articles")
    html += '>'+link_to(image_tag(Article.icon)+" Articles", items_path(Article))+'</li>'
    html += '<li '
    html += 'class="selected"' if (page=="images")
    html += '>'+link_to(image_tag(Image.icon)+" Images", items_path(Image))+'</li>'
    html += '<li '
    html += ' class="selected"' if (page=="files")
    html += '>'+link_to(image_tag(ArticFile.icon)+" Fichiers", items_path("files"))+'</li>'
    html += '<li '
    html += 'class="selected"' if (page=="videos")
    html += '>'+link_to(image_tag(Video.icon)+" Videos", items_path("videos"))+'</li>'
    html += '<li '
    html += 'class="selected"' if (page=="audios")
    html += '>'+link_to(image_tag(Audio.icon)+" Audios", items_path("audios"))+'</li>'
    html += '<li '
    html += 'class="selected"' if (page=="publications")
    html += '>'+link_to(image_tag(Publication.icon)+" Publications", items_path("publications"))+'</li>'
    html += '</ul><div class="clear"></div>'
	end
  
  def display_item_list(page)
    case page
      when "articles"
        collection = Article.all(:order => 'created_at DESC')
      when "images"
        collection = Image.all(:order => 'created_at DESC')
      when "audios"
        collection = Audio.all(:order => 'created_at DESC')
      when "videos"
        collection = Video.all(:order => 'created_at DESC')
      when "files"
        collection = ArticFile.all(:order => 'created_at DESC')
      when "publications"
        collection = Publication.all(:order => 'created_at DESC')
    end
    render(:partial => "items/item_in_list", :collection => collection)
  end
  
  private
  def self.define_prefixed_item_paths base
    # TODO: Import prefix list from a conf file
     ['edit', 'rate', 'add_tag', 'remove_tag', 'comment'].each do |prefix|
       base.send(:define_method, "#{prefix}_item_path") do |*args|
         object, params = args[0], args[1] || {}
         params[:prefix] = prefix
         item_path(object, params)
       end
     end
  end
  
end