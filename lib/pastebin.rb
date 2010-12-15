#!/usr/bin/env ruby
#
#  Class to work with http://pastebin.com
#

require 'rubygems'
require 'httpclient'
require 'rexml/document'

class Pastebin
    include REXML

    # The only option required is 'paste_code', which holds your string.
    #
    def initialize(options)
        @options = options
    end

    # This POSTs the paste and returns the link
    #
    #   pbin.paste    #=> "http://pastebin.com/xxxxxxx"
    #
    def paste
        if @options.has_key?("paste_code")
            if @options["paste_code"] == "-"
                @options["paste_code"] = $stdin.read
            else
                File.open(@options["paste_code"]) do |file|
                    @options["paste_code"] = file.read
                end
            end
        #else
        #    puts "You must specify a file or '-' for STDIN"
        #    exit
        end
        clnt = HTTPClient.new
        clnt.post("http://pastebin.com/api_public.php", @options).content
    end

    # This method takes a link from a previous paste and returns the raw
    # text.
    #
    #   pbin.get_raw("http://pastebin.com/xxxxxxx")    #=> "some text"
    #
    def get_raw(link)
        clnt = HTTPClient.new(:agent_name => 'ruby pastebin gem')
        paste = clnt.get_content("http://pastebin.com/raw.php?i=#{link[/[\w\d]+$/]}")
        doc = Document.new(paste)
        doc.elements.to_a("//pre")[0].text
    end
end
