require 'optparse'
require 'fileutils'
require 'facets/hash/rekey'
require 'dododoc/parser'

module Dododoc

  # = Command
  #
  # The Dododoc command provides the commandline
  # interface for generating dododocumentation.

  class Command

    # == main
    # The main method is a shortcut that initializes
    # the Command class and then invokes #run.
    def self.main(*argv)
      new.run(argv)
    end

    #
    def initialize
    end

    # == name
    # Name of the project. Will be pulled from VERSION file is present,
    # unless otherwise give as a commandline option.
    def name
      @name ||= version['name']
    end

    # == output
    # Where to save generated dododocuments.
    def output
      @output ||= (name ? File.join('doc', name, 'dododoc') : 'doc/dododoc')
    end

    # == version
    # Hash of version information parsed from VERSION project file.
    def version
      @version ||= (
        if File.exist?('VERSION')
          YAML.load(File.new('VERSION')).rekey(&:to_s)
        else
          {}
        end
      )
    end

    #
    def option_parser
      OptionParser.new do |opt|
        opt.on('--output', '-o PATH', 'output directory') do |output|
          @output = output
        end

        opt.on('--name', '-n NAME', 'project unixname') do |name|
          @name = name.downcase
        end

        opt.on('--debug', 'provide debugging information') do
          $VERBOSE = true
          $DEBUG   = true
        end
      end
    end

    # == run
    # Parse files and save them results.
    def run(argv=ARGV)
      option_parser.parse!(argv)

      files = argv

      if files.empty?
        if File.exist?('.document')
          files = File.readline('.document')
        end
        files.map!{ |file| file.strip }
        files.reject!{ |file| /^\#/ =~ file || /^\s+$/ =~ file }
      end

      parser = Parser.new(files)

      parser.process

      save(parser.docs)
    end

    #
    def save(docs)
      document = ""
      docs.each do |file, out|
        document << out + "<br/>"
      end
      FileUtils.mkdir_p(output)
      dest  = File.join(output, 'index.html')
      File.open(dest, 'w') do |f|
        f << document
      end
    end

  end

end

