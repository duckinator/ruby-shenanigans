#!/usr/bin/env ruby

FailedAssertionError = Class.new(ArgumentError)

class Any
  def self.===(arg)
    true
  end
end
class AnyOf < Array
  def self.[](*args)
    self.new(args)
  end

  def ===(arg)
    self.any? { |x| validate(x, [arg]) }
  end
end
module Kernel
  def argy(name)
    return self.class.send(__method__, name) unless self.is_a?(Module)

    method_ = method(name) rescue instance_method(name)
    method_ = method_.unbind if method_.respond_to?(:unbind)
    arg_names = method_.parameters.map(&:last).map(&:to_s)

    define_method(name) do |*arg_values|
      arg_values.each_with_index do |value, idx|
        binding.local_variable_set(arg_names[idx], value)
      end

      define_singleton_method(:arguments) do
        arg_names.zip(arg_values).to_h
      end

      method_.bind(self).call(*arg_values)
    end
  end

  def validate!(*assertions, arguments)
    assertions.zip(arguments).each do |assertion, (_, argument)|
      unless assertion === argument
        raise FailedAssertionError, "expected #{assertion}, got #{argument.inspect}"
      end
    end

    true
  end

  def validate(*assertions, arguments)
    validate!(*assertions, arguments)
  rescue FailedAssertionError
    false
  end
end

argy def foo(a, b, c, d)
  validate!(String, Numeric, Any, AnyOf[nil, ->(x) { x.even? }],
            arguments)
end

class Foo
  argy def bar(a, b, c, d)
    arguments
  end
end

p foo("hi", 2, 3, 4)
p foo("meep", 2, 3, nil)
p foo("meep", 2, 3, 6)
p foo(1, 2, 3, 4)
#p Foo.new.bar(1, 2, 3, 4)
