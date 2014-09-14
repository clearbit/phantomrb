module Phantomrb
  class Configuration
    attr_reader :options, :executable

    def initialize(options = {})
      @options    = options
      @executable = 'phantomjs'
    end

    def option(key, value)
      @options[key] = value
    end

    def merge(options)
      Configuration.new(@options.merge(options))
    end

    def to_options
      @options.inject({}) do |hash, (key, value)|
        hash[key.to_s.gsub('_', '-')] = value
        hash
      end
    end

    def to_s
      to_options.reduce(@executable) do |memo, (key, value)|
        "#{memo} --#{key}=#{value}"
      end
    end
  end
end
