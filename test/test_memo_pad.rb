# frozen_string_literal: true

require "test_helper"

class CallTracker
  def initialize
    @calls = {}
  end

  def track(method_name, return_value)
    @calls[method_name] ||= 0
    @calls[method_name] += 1

    return_value
  end

  def count(method_name)
    @calls.fetch(method_name, 0)
  end
end

class ClassWithMemoPad
  include MemoPad

  attr_reader :call_tracker

  def initialize
    @call_tracker = CallTracker.new
  end

  def no_arguments_truthy
    memo_pad.call(:no_arguments) do
      @call_tracker.track(:no_arguments, true)
    end
  end

  def no_arguments_falsey
    memo_pad.call(:no_arguments) do
      @call_tracker.track(:no_arguments, nil)
    end
  end
end

describe MemoPad do
  describe "::VERSION" do
    it "has a version number" do
      refute_nil MemoPad::VERSION
    end
  end

  describe "#call" do
    subject { ClassWithMemoPad.new }

    it "calls the block once for methods with no arguments" do
      assert subject.no_arguments_truthy
      subject.no_arguments_truthy

      assert_equal 1, subject.call_tracker.count(:no_arguments)
    end

    it "caches falsey values also" do
      refute subject.no_arguments_falsey
      subject.no_arguments_falsey

      assert_equal 1, subject.call_tracker.count(:no_arguments)
    end
  end
end
