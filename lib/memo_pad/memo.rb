module MemoPad
  class Memo
    attr_reader :cache

    def initialize
      @cache = Hash.new do |hash, key|
        hash[key] = {}
      end
    end

    def call(method_name, *args, &block)
      result = cache[method_name].fetch(args, &block)
      cache[method_name][args] = result
    end
  end
end
