# -*- coding: utf-8 -*-

require "haml"
require "bluecloth"
require "nokogiri"
require "fileutils"

def template_init
  template = open("./template.haml").read
  Haml::Engine.new(template, { :format => :html5 }).render
end

if __FILE__ == $0
  new_text = open(ARGV.first).read
  new_text_html = BlueCloth.new(new_text).to_html
  new_article = "<article>" + new_text_html + "</article>"
  
  home = "./index.html"
  template =  home ? open(home).read : template_init
  
  nkgr = Nokogiri::HTML.new(template)
  entries_posted = nkgr.css("article").to_html
  added = new_article + "\n" + entries_posted
  
  updated = template_init.gsub("REPLACE HERE",added)
  FileUtils.mv(home,"#{home}.#{Time.now}") if File.exist?(home)
  open(home,"w"){|f| f.puts(updated) }
end
