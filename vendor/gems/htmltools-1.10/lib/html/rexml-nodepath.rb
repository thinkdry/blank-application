# This module adds method 'full_path' to REXML hierarchy
# This method will print out the path to the given node, for example
#  /html/body/p[0]/@text
#
# Copyright::   Copyright (C) 2004, Johannes Brodwall <johannes@brodwall.com>
# License::     Same as Ruby's
# CVS ID:       $Id: rexml-nodepath.rb,v 1.5 2005/05/25 17:38:45 jhannes Exp $


module REXML
  class Child
    def parent_path
        parent ? parent.full_path : ''
    end
  end

  class Document
    def full_path
      ''
    end
  end

  class Element
    def child_index
      return "" unless parent
      siblings = parent.to_a.select do |node| 
        node.kind_of? Element and node.expanded_name == self.expanded_name
      end
      return "" if siblings.size < 2
      "[" + (siblings.index(self)+1).to_s + "]"
    end

    def full_path
      parent_path + '/' + expanded_name + child_index
    end
  end

  class Text
    def full_path
      parent_path + '/text()' + " " + expanded_name
    end
  end
  
  class Attribute
    def full_path
      element.full_path + '/@' + name
    end  
  end
end
