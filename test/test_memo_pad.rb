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

  def no_arguments
    memo_pad.fetch(:no_arguments) do
      call_tracker.track(:no_arguments, rand)
    end
  end

  def no_arguments_truthy
    memo_pad.fetch(:no_arguments_truthy) do
      call_tracker.track(:no_arguments_truthy, true)
    end
  end

  def no_arguments_falsey
    memo_pad.fetch(:no_arguments_falsey) do
      call_tracker.track(:no_arguments_falsey, nil)
    end
  end

  def no_arguments_and_raise
    memo_pad.fetch(:no_arguments_and_raise) do
      raise StandardError, "Test that this handles something bad happening"
      call_tracker.track(:no_arguments_and_raise, nil) # rubocop:disable Lint/UnreachableCode
    end
  end

  def with_arguments(foo)
    memo_pad.fetch(:with_arguments, foo) do
      call_tracker.track(:with_arguments, foo)
    end
  end
end

class MemoizeClassMethods
  include MemoPad

  def self.call_tracker
    @call_tracker ||= CallTracker.new
  end

  def self.no_arguments_class_method
    memo_pad.fetch(:no_arguments_class_method) do
      call_tracker.track(:no_arguments, true)
    end
  end
end

describe MemoPad do
  subject { ClassWithMemoPad.new }

  describe "::VERSION" do
    it "has a version number" do
      refute_nil MemoPad::VERSION
    end
  end

  describe "#fetch" do
    it "calls the block once for methods with no arguments" do
      assert subject.no_arguments_truthy
      subject.no_arguments_truthy

      assert_equal 1, subject.call_tracker.count(:no_arguments_truthy)
    end

    it "caches falsey values also" do
      refute subject.no_arguments_falsey
      subject.no_arguments_falsey

      assert_equal 1, subject.call_tracker.count(:no_arguments_falsey)
    end

    it "does not share cached values between instances" do
      subject1 = ClassWithMemoPad.new
      subject2 = ClassWithMemoPad.new
      value1 = "foo"
      value2 = "bar"

      assert_equal value1, subject1.with_arguments(value1)

      assert_equal 1, subject1.call_tracker.count(:with_arguments)
      assert_equal 0, subject2.call_tracker.count(:with_arguments)

      assert_equal value1, subject1.with_arguments(value1)
      assert_equal value2, subject2.with_arguments(value2)

      assert_equal 1, subject1.call_tracker.count(:with_arguments)
      assert_equal 1, subject2.call_tracker.count(:with_arguments)
    end

    it "raises any errors without caching" do
      assert_raises(StandardError) do
        subject.no_arguments_and_raise
      end

      assert_equal 0, subject.call_tracker.count(:no_arguments_and_raise)
    end

    it "can be used in class methods" do
      assert MemoizeClassMethods.no_arguments_class_method
      MemoizeClassMethods.no_arguments_class_method

      assert_equal 1, MemoizeClassMethods.call_tracker.count(:no_arguments)
    end
  end

  describe "#write" do
    let(:result) { rand }

    it "writes the given value to be read later" do
      subject.memo_pad.write(:no_arguments, value: result)

      assert_equal result, subject.memo_pad.read(:no_arguments)
      assert_equal result, subject.no_arguments
    end

    it "writes the given value for methods with arguments" do
      subject.memo_pad.write(:with_arguments, :foo, value: result)

      assert_equal result, subject.memo_pad.read(:with_arguments, :foo)
      assert_nil subject.memo_pad.read(:with_arguments, :bar)
      assert_nil subject.memo_pad.read(:with_arguments)
    end
  end

  describe "#read" do
    let(:arg) { rand }

    it "returns nil if no cached value present" do
      assert_nil subject.memo_pad.read(:no_arguments)
    end

    it "it reads a cached value if present" do
      result = subject.no_arguments

      assert_equal result, subject.memo_pad.read(:no_arguments)
    end

    it "reads a cached value for method with arguments" do
      result = subject.with_arguments(arg)

      assert_equal result, subject.memo_pad.read(:with_arguments, arg)
      assert_nil subject.memo_pad.read(:with_arguments, :foo)
      assert_nil subject.memo_pad.read(:with_arguments)
    end
  end

  describe "#read!" do
    let(:arg) { rand }

    it "raises KeyError if no cached value present" do
      assert_raises(KeyError) do
        subject.memo_pad.read!(:no_arguments)
      end
    end

    it "it reads a cached value if present" do
      result = subject.no_arguments

      assert_equal result, subject.memo_pad.read!(:no_arguments)
    end

    it "reads a cached value for method with arguments" do
      result = subject.with_arguments(arg)

      assert_equal result, subject.memo_pad.read!(:with_arguments, arg)

      assert_raises(KeyError) do
        subject.memo_pad.read!(:with_arguments, :foo)
      end

      assert_raises(KeyError) do
        subject.memo_pad.read!(:with_arguments)
      end
    end
  end

  describe "#clear" do
    it "empties any memoized values" do
      subject.memo_pad.write(:foo, value: "bar")
      subject.memo_pad.write(:bar, :baz, value: "quux")

      subject.memo_pad.clear

      assert_nil subject.memo_pad.read(:foo)
      assert_nil subject.memo_pad.read(:bar, :baz)
    end
  end
end
