# apple_help.rb
# Superclass for all other help templates
# buildtools
#
# Copyright 2007-2010 Wincent Colaiuta. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

require 'walrus/document'
require 'walrus/contrib/walruscloth'
require 'erb'

module Walrus
  class WalrusGrammar
    class AppleHelp < Document
      include ERB::Util

      # Returns true if the WALRUS_STYLE environment variable is set to 'web'
      def web_based?
        ENV['WALRUS_STYLE'] == 'web'
      end

      # Returns true if the current page is the front page. Does this by
      # checking to see if he value for 'tag' has been set to 'front_page'
      def front_page?
        get_value(:tag) == 'front_page'
      end

      # Takes the abstract previously registered using the #set directive and
      # generates meta markup for recognition by the Help Indexer. If no
      # abstract has been explicitly registered tries falling back and using
      # the page_title. If no page_title has been registered returns an empty
      # string. In practice this method is never used by inheriting templates;
      # it is used by the top-level templates from which the others inherit.
      def abstract
        abstract = get_value(:abstract)
        abstract = get_value(:page_title) if abstract == ''
        (abstract != '') ? %Q{<meta name="description" content="#{html_escape abstract}">} : ''
      end

      # Allows you to define additional keywords that will be detected by the
      # Help Indexer. Call this from the setup block in each template to ensure
      # keywords are registered before the HTML head is emitted. There is no
      # need to define keywords if those words already appear elsewhere on the
      # page. This method is for adding keywords which do not exist in the page
      # text (synonyms or common misspellings). As the list is comma separated
      # and quote-delimited, your input values should not themselves include
      # commas or quotes. Example: keywords('registering', 'registration')
      def keywords(*words)
        @keyword_list = words.join(', ') and '' # make sure no output gets echoed
      end

      # Takes keywords previously registered using the keywords method and
      # generates meta markup for recognition by the Help Indexer. If no
      # keywords have been registered returns an empty string. In practice this
      # method is never used by inheriting templates; it is used by the
      # top-level templates from which the others inherit.
      def keyword_meta
        (@keyword_list.nil?) ? '' : %Q{<meta name="keywords" content="#{html_escape @keyword_list}">}
      end

      # Insert a link to the target page.
      #
      # If text is nil the target text is used with underscores removed
      #
      # This method can output in two possible formats:
      #
      # - a Help Viewer anchor
      # - relative HTML link (for uploading to website)
      #
      # Ultimately, link_to_category will output an empty string for the online
      # format. Empty strings would be shown in the "see also" listing.
      # link_to_category should therefore only be used in conjunction with the
      # "see also" feature.
      #
      # target should be an anchor or base filename. For example, to link to a
      # page "foo_bar.html" target would be "foo_bar". text is the
      # human-readable (clickable) text for the link.
      def link_to(target, text = nil)
        text = target.gsub(/_/, ' ') if text.nil?
        if web_based?
          if front_page?
            %Q{<a href="pages/#{html_escape target}.html">#{html_escape text}</a>}
          else
            if target == 'front_page'
              %Q{<a href="../#{html_escape target}.html">#{html_escape text}</a>}
            else
              %Q{<a href="#{html_escape target}.html">#{html_escape text}</a>}
            end
          end
        else
          %Q{<a href="help:anchor='#{html_escape target}' bookID=#{book_id}">#{html_escape text}</a>}
        end
      end

      # Add the current page to the specified category or categories.
      #
      # Call this from the setup block in each template to ensure categories
      # are registered before the HTML body starts emission. The category
      # identifier, cat, need not be "human readable" and is not localized.
      # Apple help books use lowercase, alphanumeric category names with no
      # spaces, so it is recommended to follow the same convention.
      def category(*cats)
        @categories = [] if @categories.nil?
        @categories.concat(cats) and '' # make sure no output gets echoed
      end

      # Takes the previously registered categories and returns output that will
      # be recognized by the Help Indexer.
      #
      # If no categories have been registered returns an empty string. In
      # practice this method is never used by inheriting templates; it is used
      # by the top-level templates from which the others inherit. Including an
      # empty anchor tag is sufficient to include a page in a category. See:
      # http://andymatuschak.org/articles/2005/12/18/help-with-apple-help
      def categories
        (@categories.nil?) ? '' : @categories.collect { |cat| %Q{<a name="#{html_escape cat}"></a>} }.join("\n")
      end

      # category is the name of the anchor in the HTML source (not localized).
      # label is displayed in the header at the top of the generated page and
      # also in the link; it should be localized. label is HTML escaped
      # automatically. Apple help books use lowercase, alphanumeric category
      # names with no spaces. Note that category links won't work on the
      # web-based version of the help; no output is produced.
      def link_to_category(category, label = nil)
        return '' if web_based?

        label = category.gsub(/_/, ' ') if label.nil?
        # note that the bookID is not quoted even though it contains a space
        # likewise, Other may contain spaces even though it is not quoted
        #
        # in Apple help books non-ASCII characters in Other are not escaped
        # (note that the template is UTF-8 encoded) template and stylesheet are
        # paths relative to the help book folder
        %Q{<a href="help:topic_list=#{html_escape category}
                         bookID=#{book_id}
                         template=autogen/generated_list.html
                         stylesheet=autogen/generated_list.css
                         Other=#{html_escape label}">#{html_escape label}</a>}.gsub(/\s+/, ' ')
      end

      # Expects a link created using the link or link_to_category method.
      # Appends the supplied link to the list of "See also" items for the
      # current page.
      def see_also(link)
        @see_also = [] if @see_also.nil?
        (@see_also << link) and '' # make sure no output gets echoed
      end

      # Takes the previously registered "See also" items and returns an HTML
      # list representation.
      #
      # If no items have been registered returns an empty string. Note that
      # this method should only be called from basic.tmpl or one of its
      # subclasses (ie from a page that implements the see_also_div method).
      # The in-template method is used for localization purposes, so that
      # localization can take place independently of this class.
      def see_also_list
        if @see_also.nil?
          ''
        else
          list = @see_also.collect do |item|
            if item != ''
              %Q{<p>#{item}</p>}
            else
              ''  # handle blank category links in web-based version
            end
          end
          # beware that all items could be ''; in that case shouldn't emit
          # anything for web-based version
          (list.any? { |item| item != '' }) ? lookup_and_return_placeholder(:see_also_div, list.join("\n")) : ''
        end
      end

      def index_item(item_html)
        @index_items = [] if @index_items.nil?
        @index_items << item_html
        ''
      end

      # TODO: could be expressed slightly more elegantly with a #for construct
      # inside the template itself
      def index_rows
        return '' if @index_items.nil?
        items = @index_items.collect do |item|
          <<-DOC
        <tr>
          <td>
            <p>#{item}</p>
            </td>
        </tr>
          DOC
        end
        items.join("\n")
      end

      # Pumps the passed-in text through WalrusCloth (Textile).
      def cloth(text)
        WalrusCloth.new(text).to_html
      end

      # Returns the value of the book_id placeholder, automatically HTML
      # escaped.
      def book_id
        html_escape(get_value(:book_id))
      end

      # Returns the value of the book_icon placeholder, automatically URL
      # encoded and HTML escaped.
      def book_icon
        html_escape(url_encode(get_value(:book_icon)))
      end

      # Returns the value of the page_title placeholder, automatically HTML
      # escaped.
      def page_title
        html_escape(get_value(:page_title))
      end

      # For this method to produce output the #set directive must have been
      # previously used to tag a page with a particular label. Typically this
      # should occur in the setup block.
      def tag
        tag = get_value(:tag)
        (tag != '') ? %Q{<a name="#{html_escape tag}"></a>\n} : ''
      end
    end # class AppleHelp
  end # class WalrusGrammar
end # module Walrus
