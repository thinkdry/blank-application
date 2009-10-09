# 
# To change this template, choose Tools | Templates
# and open the template in the editor.


ALPHA_AND_EXTENDED = '[a-zA-Z\'éèêëôöàäùüç]'
SPECIAL = '[\'\ \-]'
NUM = '[0-9]'
URL = '^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$'

RE_EMAIL_NAME   = '[\w\.%\+\-]+'                          # what you actually see in practice
#RE_EMAIL_NAME   = '0-9A-Z!#\$%\&\'\*\+_/=\?^\-`\{|\}~\.' # technically allowed by RFC-2822
RE_DOMAIN_HEAD  = '(?:[A-Z0-9\-]+\.)+'
RE_DOMAIN_TLD   = '(?:[A-Z]{2}|com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum)'
RE_EMAIL_OK     = /\A#{RE_EMAIL_NAME}@#{RE_DOMAIN_HEAD}#{RE_DOMAIN_TLD}\z/i
SCRIPTING_TAGS = '<(\S+).*>(|.*)<\/(\S+).*>|<%(.*)%>|<%=(.*)%>'
PHONE = /\A(\d|\+|-|\(|\)|\s)+\Z/


