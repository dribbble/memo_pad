# frozen_string_literal: true

require_relative "memo_pad/version"
require_relative "memo_pad/memo"

module MemoPad
  class Error < StandardError; end

  def memo_pad
    @memo_pad ||= MemoPad::Memo.new
  end
end
