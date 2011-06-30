require 'coderay'
require 'nokogiri'
require 'fileutils'
require 'erb'

require 'apitap/cli'

#
class APITap

  #
  DIRECTORY = File.dirname(__FILE__)

  def initialize(scripts)
    files = scripts.map do |glob|
      glob = File.join(glob, '**/*') if File.directory?(glob)
      Dir[glob]
    end.flatten
    @scripts = files.select{ |f| File.file?(f) && File.extname(f) == '.rb' }  # TODO: more than just .rb
  end

  # list of source files
  def scripts
    @scripts
  end

  # build single html page with each file
  def build
    html = []
    scripts.each do |script|
      code = File.read(script)
      html << %[<div class="file" id="#{script}"><pre>]
      html << highlight(code)
      html << %[</pre></div>]
    end
    text = html.join("\n")
    text = interlink(text)
    text = garnish(text)
    text
  end

  # run syntax highlighter over all code
  def highlight(code)
    CodeRay.scan(code, :ruby).div(:css => :class)
  end

  # generate interlinks
  def interlink(text)
    html = Nokogiri::HTML.fragment(text)
    meths = []
    html.css('.fu').each do |node|
      meths << node.text
      node['id'] = "fu-#{node.text}"
    end
    meths.each do |meth|
      html.xpath("//*[contains(text(),'#{meth}')]").each do |node|
$stderr << node.inner_html
        node.inner_html = node.inner_html.gsub(meth, %{<a href="fu-#{meth}">#{meth}</a>})
      end
    end
    html.to_s
  end

  # add any additional elements (toc, serachbar)
  def garnish(html)
    template{ html }
  end

  #
  def template(&block)
    tmp = File.read(File.join(DIRECTORY, 'apitap', 'template.rhtml'))
    erb = ERB.new(tmp)
    erb.result(binding)
  end

  #
  def save(output)
    output ||= 'tap'
    FileUtils.mkdir_p(output)
    index = File.join(output, 'index.html')
    File.open(index, 'w'){ |f| f << build }
    FileUtils.cp(File.join(DIRECTORY, 'apitap', 'coderay.css'), output)
  end

end

