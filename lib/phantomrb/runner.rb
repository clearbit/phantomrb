require 'ostruct'
require 'shellwords'

module Phantomrb
  class Runner
    def initialize
      @config = Phantomrb.configuration
    end

    def run(script, *args, &block)
      options   = args.last.is_a?(Hash) ? args.pop : {}
      command   = @config.merge(options)
      sargs     = args.map {|a| Shellwords.escape(a) }

      command_line = [
        command,
        full_script_path(script),
        *sargs
      ].join(' ')

      p command_line

      begin
        process = IO.popen(command_line)
      rescue => e
        raise ExecutableLoadError.new(e)
      end

      output = capture_output(process, &block)
      process.close

      unless $?.exitstatus == 0
        raise ScriptRuntimeError.new(output)
      end

      OpenStruct.new(
        output: output,
        exit_status: $?.exitstatus,
        command_line: command_line
      )
    end

    private

    def full_script_path(script)
      full_script_path = File.expand_path(script)
      if File.file?(full_script_path)
        full_script_path
      else
        raise ScriptLoadError.new("#{full_script_path} not found")
      end
    end

    def capture_output(process)
      if block_given?
        output = ''
        process.each_line do |output_line|
          output << output_line
          yield(output_line)
        end
        output
      else
        process.read
      end
    end
  end
end
