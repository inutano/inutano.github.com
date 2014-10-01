# -*- coding: utf-8 -*-

require "haml"
require "bluefeather"
require "nokogiri"
require "fileutils"

def template_init
  template = open("./template.haml").read
  Haml::Engine.new(template, { :format => :html5 }).render
end

class Articolo
  def initialize(testo)
    @testo = testo
  end
  
  def al_html
    BlueFeather.parse(@testo)
  end
  
  def titlo
    linea_prima = @testo.split("\n").first
    linea_prima.gsub(/^\#+\s/,"")
  end
  
  def id
    self.titlo.gsub("\s","_")
  end
  
  def link
    base = "http://inutano.github.com/\#"
    base + self.id
  end
  
  def autori(autoro="tazro inutano")
    autoro
  end
  
  def created_at
    Time.now
  end
  
  def article_tagged
    "<article id='#{self.id}'>" + self.al_html + "</article>"
  end
  
  def testo_per_rss
    html = self.al_html
    testo_array = html.split("\n")
    titolo = testo_array.shift
    "<![CDATA[" + testo_array.join("\n") + "]]"
  end
end

if __FILE__ == $0
  new_text = File.read(ARGV.first)
  articolo = Articolo.new(new_text)
  
  home = "./index.html"
  template = File.exist?(home) ? open(home).read : template_init
  
  nkgr = Nokogiri::HTML(template)
  entries_posted = nkgr.css("article").to_html
  added = articolo.article_tagged + "\n" + entries_posted
  
  updated = template_init.gsub("REPLACE HERE",added)
  FileUtils.mv(home,"./prev_index/#{home}.#{Time.now.strftime("%Y%m%d%H%M%S")}") if File.exist?(home)
  open(home,"w"){|f| f.puts(updated) }
  
  # RSS
  rss_template = open("./rss.haml").read
  engine = Haml::Engine.new(rss_template)
  rss_text = engine.render(articolo)
  rdf = "./rss/index.rdf"
  FileUtils.mv(rdf, "#{rdf}.#{Time.now.strftime("%Y%m%d%H%M%S")}") if File.exist?(rdf)
  open(rdf,"w"){|f| f.puts(rss_text) }
end
