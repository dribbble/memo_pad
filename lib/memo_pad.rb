# frozen_string_literal: true

require_relative "memo_pad/version"
require_relative "memo_pad/memo"

# Add memoization to a class with:
#
#   class Foo
#     include MemoPad
#   end
#
# Memoize results of complex executions on its memo_pad:
#
#   def expensive_method
#     memo_pad.fetch(:expensive_method) do
#       # perform the expensive work
#     end
#   end
#
# Pass in any arguments that the memoized result would depend on, if any:
#
#   def expensive_with_arguments(foo, bar: nil)
#     memo_pad.fetch(:expensive_with_arguments, foo, bar) do
#       # perform the expensive work
#     end
#   end
module MemoPad
  def self.included(klass)
    def klass.memo_pad
      @@memo_pad ||= MemoPad::Memo.new
    end
  end

  def memo_pad
    @memo_pad ||= MemoPad::Memo.new
  end
end
