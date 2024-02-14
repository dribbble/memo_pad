# frozen_string_literal: true

module MemoPad
  # Hold memoized results for an instance.
  class Memo
    attr_reader :cache

    def initialize
      @cache = Hash.new do |hash, key|
        hash[key] = {}
      end
    end

    def fetch(method_name, *args, &block)
      read!(method_name, *args)
    rescue KeyError
      write(method_name, *args, value: block.call)
    end

    def read(method_name, *args)
      cache[method_name].fetch(args, nil)
    end

    def read!(method_name, *args)
      cache[method_name].fetch(args)
    end

    def write(method_name, *args, value:)
      cache[method_name][args] = value
    end
  end
end
