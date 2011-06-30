class APITap

  #
  def self.cli(argv=ARGV)
    require 'optparse'

    cli_parser.parse!(argv)

    output = cli_options[:output]
    files  = argv

    apitap = new(files)

    if output
      apitap.save(output)
    else
      puts apitap.build
    end
  end

  #
  def self.cli_parser
    OptionParser.new do |opt|
      opt.on('-o', '--output=DIR', 'save to output directory') do |dir|
        cli_options[:output] = dir
      end
      opt.on_tail('--help', 'show this help message') do
        puts opt
        exit
      end
      opt.on_tail('--debug', 'run in debug mode') do
        $DEBUG = true
      end
    end
  end

  #
  def self.cli_options
    @cli_options ||= {}
  end

end
