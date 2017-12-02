#!/usr/bin/env ruby

module Kernel
  def fuck(name)
    return self.class.fuck(name) unless self.is_a?(Module)

    method_ = method(name) rescue instance_method(name)
    method_ = method_.unbind if method_.respond_to?(:unbind)
    arg_names = method_.parameters.map(&:last).map(&:to_s)

    define_method(name) do |*arg_values|
      arg_values.each_with_index { |value, idx|
        binding.local_variable_set(arg_names[idx], value)
      }
      define_singleton_method(:arguments) do
        arg_names.zip(arg_values).to_h
      end

      method_.bind(self).call(*arg_values)
    end
  end
end

fuck def foo(a, b, c, d)
  arguments
end

class Foo
  fuck def bar(a, b, c, d)
    arguments
  end
end

p foo(1, 2, 3, 4)
p Foo.new.bar(1, 2, 3, 4)
