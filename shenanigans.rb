#!/usr/bin/env ruby

def fuck(name)
  method_ = method(name)
  arg_names = method_.parameters.map(&:last).map(&:to_s)

  receiver_ = method_.receiver
  receiver_ = receiver_.class unless receiver_.is_a?(Module)

  receiver_.class_eval do
    define_method(name) do |*args|
      args.each_with_index { |value, idx|
        binding.local_variable_set(arg_names[idx], value)
      }
      define_method(:arguments) do
        arg_values = args
        arg_names.zip(arg_values).to_h
      end

      method_.call(*args)
    end
  end
end

fuck def foo(a, b, c, d)
  arguments
end

p foo(1, 2, 3, 4)
