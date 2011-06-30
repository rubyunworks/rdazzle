require 'dododoc/markup'

module Dododoc

  #
  class Parser

    #
    attr :raw

    #
    attr :docs

    #
    def initialize(files)
      @files = files
    end

    #
    def process
      parse
      render
    end

    #
    def render
      docs = []
      @raw.each do |(file, text)|
        docs << [file, markup.render(text)]
      end
      @docs = docs
    end

    # == script
    # TODO: no .rb ?
    def files
      @files.map do |file|
        if File.directory?(file)
          Dir[File.join(file, '**', '*.rb')]
        else
          file
        end
      end.flatten
    end

    #
    def parse
      docs = []
      files.each do |file|
        next if File.directory?(file)
        doc = []
        File.readlines(file).each do |line|
          if /^\s*\#/ =~ line
            doc << line.sub(/^\s*\#\s*/, '')
          end
        end
        docs << [file, doc.join("\n")]
      end
      @raw = docs
    end

    #
    def markup
      @markup ||= Markup.new
    end

  end

end

