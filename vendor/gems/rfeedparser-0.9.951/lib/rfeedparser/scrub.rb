#!/usr/bin/env ruby
# This used to be based on Michael Moen's Hpricot#scrub, but that seems to 
# have only been part of its evolution. Hpricot#scrub is cool code, though.
# http://underpantsgnome.com/2007/01/20/hpricot-scrub
module Hpricot
  Acceptable_Elements = ['a', 'abbr', 'acronym', 'address', 'area', 'b',
    'big', 'blockquote', 'br', 'button', 'caption', 'center', 'cite',
    'code', 'col', 'colgroup', 'dd', 'del', 'dfn', 'dir', 'div', 'dl', 'dt',
    'em', 'fieldset', 'font', 'form', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
    'hr', 'i', 'img', 'input', 'ins', 'kbd', 'label', 'legend', 'li', 'map',
    'menu', 'ol', 'optgroup', 'option', 'p', 'pre', 'q', 's', 'samp',
    'select', 'small', 'span', 'strike', 'strong', 'sub', 'sup', 'table',
    'tbody', 'td', 'textarea', 'tfoot', 'th', 'thead', 'tr', 'tt', 'u',
    'ul', 'var'
  ]

  Acceptable_Attributes = ['abbr', 'accept', 'accept-charset', 'accesskey',
    'action', 'align', 'alt', 'axis', 'border', 'cellpadding',
    'cellspacing', 'char', 'charoff', 'charset', 'checked', 'cite', 'class',
    'clear', 'cols', 'colspan', 'color', 'compact', 'coords', 'datetime',
    'dir', 'disabled', 'enctype', 'for', 'frame', 'headers', 'height',
    'href', 'hreflang', 'hspace', 'id', 'ismap', 'label', 'lang',
    'longdesc', 'maxlength', 'media', 'method', 'multiple', 'name',
    'nohref', 'noshade', 'nowrap', 'prompt', 'readonly', 'rel', 'rev',
    'rows', 'rowspan', 'rules', 'scope', 'selected', 'shape', 'size',
    'span', 'src', 'start', 'summary', 'tabindex', 'target', 'title', 
    'type', 'usemap', 'valign', 'value', 'vspace', 'width', 'xml:lang'
  ]

  Unacceptable_Elements_With_End_Tag = ['script', 'applet']

  Acceptable_Css_Properties = ['azimuth', 'background-color',
    'border-bottom-color', 'border-collapse', 'border-color',
    'border-left-color', 'border-right-color', 'border-top-color', 'clear',
    'color', 'cursor', 'direction', 'display', 'elevation', 'float', 'font',
    'font-family', 'font-size', 'font-style', 'font-variant', 'font-weight',
    'height', 'letter-spacing', 'line-height', 'overflow', 'pause',
    'pause-after', 'pause-before', 'pitch', 'pitch-range', 'richness',
    'speak', 'speak-header', 'speak-numeral', 'speak-punctuation',
    'speech-rate', 'stress', 'text-align', 'text-decoration', 'text-indent',
    'unicode-bidi', 'vertical-align', 'voice-family', 'volume',
    'white-space', 'width'
  ]

  # survey of common keywords found in feeds
  Acceptable_Css_Keywords = ['auto', 'aqua', 'black', 'block', 'blue',
    'bold', 'both', 'bottom', 'brown', 'center', 'collapse', 'dashed',
    'dotted', 'fuchsia', 'gray', 'green', '!important', 'italic', 'left',
    'lime', 'maroon', 'medium', 'none', 'navy', 'normal', 'nowrap', 'olive',
    'pointer', 'purple', 'red', 'right', 'solid', 'silver', 'teal', 'top',
    'transparent', 'underline', 'white', 'yellow'
  ]

  Mathml_Elements = ['maction', 'math', 'merror', 'mfrac', 'mi',
    'mmultiscripts', 'mn', 'mo', 'mover', 'mpadded', 'mphantom',
    'mprescripts', 'mroot', 'mrow', 'mspace', 'msqrt', 'mstyle', 'msub',
    'msubsup', 'msup', 'mtable', 'mtd', 'mtext', 'mtr', 'munder',
    'munderover', 'none'
  ]

  Mathml_Attributes = ['actiontype', 'align', 'columnalign', 'columnalign',
    'columnalign', 'columnlines', 'columnspacing', 'columnspan', 'depth',
    'display', 'displaystyle', 'equalcolumns', 'equalrows', 'fence',
    'fontstyle', 'fontweight', 'frame', 'height', 'linethickness', 'lspace',
    'mathbackground', 'mathcolor', 'mathvariant', 'mathvariant', 'maxsize',
    'minsize', 'other', 'rowalign', 'rowalign', 'rowalign', 'rowlines',
    'rowspacing', 'rowspan', 'rspace', 'scriptlevel', 'selection',
    'separator', 'stretchy', 'width', 'width', 'xlink:href', 'xlink:show',
    'xlink:type', 'xmlns', 'xmlns:xlink'
  ]

  # svgtiny - foreignObject + linearGradient + radialGradient + stop
  Svg_Elements = ['a', 'animate', 'animateColor', 'animateMotion',
    'animateTransform', 'circle', 'defs', 'desc', 'ellipse', 'font-face',
    'font-face-name', 'font-face-src', 'g', 'glyph', 'hkern', 'image',
    'linearGradient', 'line', 'metadata', 'missing-glyph', 'mpath', 'path',
    'polygon', 'polyline', 'radialGradient', 'rect', 'set', 'stop', 'svg',
    'switch', 'text', 'title', 'use'
  ]

  # svgtiny + class + opacity + offset + xmlns + xmlns:xlink
  Svg_Attributes = ['accent-height', 'accumulate', 'additive', 'alphabetic',
    'arabic-form', 'ascent', 'attributeName', 'attributeType',
    'baseProfile', 'bbox', 'begin', 'by', 'calcMode', 'cap-height',
    'class', 'color', 'color-rendering', 'content', 'cx', 'cy', 'd',
    'descent', 'display', 'dur', 'end', 'fill', 'fill-rule', 'font-family',
    'font-size', 'font-stretch', 'font-style', 'font-variant',
    'font-weight', 'from', 'fx', 'fy', 'g1', 'g2', 'glyph-name', 
    'gradientUnits', 'hanging', 'height', 'horiz-adv-x', 'horiz-origin-x',
    'id', 'ideographic', 'k', 'keyPoints', 'keySplines', 'keyTimes',
    'lang', 'mathematical', 'max', 'min', 'name', 'offset', 'opacity',
    'origin', 'overline-position', 'overline-thickness', 'panose-1',
    'path', 'pathLength', 'points', 'preserveAspectRatio', 'r',
    'repeatCount', 'repeatDur', 'requiredExtensions', 'requiredFeatures',
    'restart', 'rotate', 'rx', 'ry', 'slope', 'stemh', 'stemv', 
    'stop-color', 'stop-opacity', 'strikethrough-position',
    'strikethrough-thickness', 'stroke', 'stroke-dasharray',
    'stroke-dashoffset', 'stroke-linecap', 'stroke-linejoin',
    'stroke-miterlimit', 'stroke-width', 'systemLanguage', 'target',
    'text-anchor', 'to', 'transform', 'type', 'u1', 'u2',
    'underline-position', 'underline-thickness', 'unicode',
    'unicode-range', 'units-per-em', 'values', 'version', 'viewBox',
    'visibility', 'width', 'widths', 'x', 'x-height', 'x1', 'x2',
    'xlink:actuate', 'xlink:arcrole', 'xlink:href', 'xlink:role',
    'xlink:show', 'xlink:title', 'xlink:type', 'xml:base', 'xml:lang',
    'xml:space', 'xmlns', 'xmlns:xlink', 'y', 'y1', 'y2', 'zoomAndPan'
  ]

  Svg_Attr_Map = nil
  Svg_Elem_Map = nil

  Acceptable_Svg_Properties = [ 'fill', 'fill-opacity', 'fill-rule',
    'stroke', 'stroke-width', 'stroke-linecap', 'stroke-linejoin',
    'stroke-opacity'
  ]

  unless $compatible 
    @@acceptable_tag_specific_attributes = {}
    @@mathml_elements.each{|e| @@acceptable_tag_specific_attributes[e] = @@mathml_attributes }
    @@svg_elements.each{|e| @@acceptable_tag_specific_attributes[e] = @@svg_attributes }
  end

  class Elements 
    def strip_attributes(safe=[])
      each { |x| x.strip_attributes(safe) }
    end

    def strip_style(ok_props=[], ok_keywords=[]) # NOTE unused so far.
      each { |x| x.strip_style(ok_props, ok_keywords) }
    end
  end

  class Text
    def strip_attributes(foo)
    end
  end
  class Comment
    def strip_attributes(foo)
    end
  end
  class BogusETag
    def strip_attributes(foo)
    end
  end

  class Elem
    def strip_attributes
      unless attributes.nil?
        ra = {}
        raw_attributes.keys.each{|atr| ra[atr] = raw_attributes[atr] if Acceptable_Attributes.include?(atr) }
        self.raw_attributes = ra
      end
    end
  end
end

module FeedParserUtilities
  class SanitizerDoc < Hpricot::Doc
    
    def scrub
      others = children.map do |e|
        if e.elem?
          if Acceptable_Elements.include?e.name
            e.strip_attributes
            e.inner_html = SanitizerDoc.new(e.children).scrub
            result = e
          else
            result = e
            
            if Unacceptable_Elements_With_End_Tag.include?e.name
              result = nil
            end
            
            if result 
              result = SanitizerDoc.new(result.children).scrub   # The important part
            end            
          end
          
        elsif e.doctype?
          result = nil

        elsif e.text?
          ets = e.to_html
          ets.gsub!(/&#39;/, "'") 
          ets.gsub!(/&#34;/, '"')
          ets.gsub!(/\r/,'')
          result = ets
        end
        result
      end
      
      unless $compatible # FIXME nonworking
        # yes, that '/' should be there. It's a search method. See the Hpricot docs.
        (self/tag).strip_style(@config[:allow_css_properties], @config[:allow_css_keywords])
      end
      return others.compact.join
    end
  end

  def SanitizerDoc(html)
    SanitizerDoc.new(Hpricot.make(html))
  end
  module_function(:SanitizerDoc)

  def sanitizeHTML(html,encoding)
    # FIXME Tidy not yet supported
    html = html.gsub(/<!((?!DOCTYPE|--|\[))/, '&lt;!\1')
    h = SanitizerDoc(html)
    h = h.scrub
    return h.strip
  end
end
