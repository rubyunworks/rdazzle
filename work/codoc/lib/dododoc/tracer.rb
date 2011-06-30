require 'tracepoint'

module Dododoc

  # Tracer
  class Tracer

    #
    def initialize(*paths)
      @paths = paths
      @trace = []
      start_trace
      paths.each do |path|
        require(path)
      end
      stop_trace
    end

    #
    attr :trace

    #
    def start_trace
      TracePoint.trace do |tp|
        @trace << tp
      end
      TracePoint.activate
    end

    #
    def stop_trace
      TracePoint.clear
    end

    #
    def analyize
      cats = {:method=>[], :class=>[]}
      select.each do |tp|
        if tp.callee == :method_added
          cats[:method] << tp #[tp.self, tp.file, tp.line] 
        elsif tp.event == 'class'
          cats[:class] << tp #[tp.self, tp.file, tp.line]
        end
      end
      cats
    end

    #
    def select
      files = @paths.map{ |f| File.expand_path(f) }
      trace.select{ |tp| files.include?(File.expand_path(tp.file)) }
    end

  end

end
