require 'rdoc/markup'
require 'rdoc/markup/to_html'

module Dododoc

  class Markup

    def render(text)
      engine.convert(text)
    end

    #
    def engine
      @engine ||= (
        m = RDoc::Markup.new
        m.add_word_pair("`", "`", :CODE)
        #m.add_special(/\b([A-Z][a-z]+[A-Z]\w+)/, :WIKIWORD)
        wh = WikiHtml.new
        wh.add_tag(:CODE, "<code>", "</code>")
        wh
      )
    end

    #
    class WikiHtml < RDoc::Markup::ToHtml
      #def handle_special_WIKIWORD(special)
      #  "<font color=red>" + special.text + "</font>"
      #end
    end

  end

end
