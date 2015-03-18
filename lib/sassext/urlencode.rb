#------------------------------------------------------------------------------
# More infos: http://goo.gl/NtsErt
#

module Sass::Script::Functions
  def urlencode(string)
    Sass::Script::String.new(ERB::Util.url_encode(string.value));
  end
  declare :urlencode, :args => [:string]
end
