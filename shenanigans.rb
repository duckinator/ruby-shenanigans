#!/usr/bin/env ruby

def fuck(name)
  method_ = method(name)
  file, line = method_.source_location
  def_line = File.readlines(file)[line - 1].strip
  #args = def_line.split(name.to_s, 2).last

  receiver_ = method_.receiver
  receiver_ = receiver_.class unless receiver_.is_a?(Class)
  receiver_.class_exec {
    alias_method "__fuck_#{name}", name
    define_method(name) { |*args|
      define_method(:arguments) do
        arg_names  = method(name).parameters.map(&:last).map(&:to_s)
        arg_values = arg_names.map(&method(:eval))
        arg_names.zip(arg_values).to_h
      end

      method("__fuck_#{name}").unbind.bind(binding).call(*args)
    }
  }
end

fuck def foo(a, b, c, d)
  arguments
end

p foo(1, 2, 3, 4)
