# Inheritor, Copyright (c) 2005 Thomas Sawyer

require 'facets/class_extension'

class Object

  # Create an inheritor "class attribute".
  #
  # Inheritor providse a means to store and inherit data via
  # the class heirarchy. An inheritor creates two methods
  # one named after the key that provides a reader. And one
  # named after key! which provides the writer. (Because of
  # the unique nature of inheritor the reader and writer
  # can't be the same method.)
  #
  #   class X
  #     inheritor :foo, [], :+
  #   end
  #
  #   class Y < X
  #   end
  #
  #   X.x! << :a
  #   X.x => [:a]
  #   Y.x => [:a]
  #
  #   Y.x! << :b
  #   X.x => [:a]
  #   Y.x => [:a, :b]
  #
  # It is interesting to note that the inheritor would be much less useful
  # if Ruby allowed modules to be "inherited" at the class-level, or conversely
  # that the class-level is handled as a module instead. Because if it were,
  # using #super at the class-level would make it fairly easy to implement
  # this behavior by hand.
  #
  def inheritor(key, obj, op=nil)

    # inhertiance operator
    op = op ? op.to_sym : :add  #NOTE: why #add ?

    # inheritor store a this level
    instance_variable_set("@#{key}", obj)

    #base = self
    deflambda = lambda do

      define_method( key ) do
        defined?(super) ? super.__send__(op,obj) : obj.dup
      end

      define_method( "#{key}!" ) do
        if instance_variable_defined?("@#{key}")
          instance_variable_get("@#{key}")
        else
          inheritor(key, obj.class.new, op)
        end
        # -- old version --
        #if instance_variables.include?("@#{key}")
        #  instance_variable_get("@#{key}")
        #else
        #  if self != base
        #    inheritor( key, obj.class.new, op )
        #  end
        #end
      end
    end

    # TODO: This is an issue if you try to include a module
    #       into Module or Class itself. How to fix?

    # if the object is a module (not a class or other object)
    if self == Class or self == Module
      class_eval(&deflambda)
    elsif is_a?(Class)
      (class << self; self; end).class_eval(&deflambda)
    elsif is_a?(Module)
      #class_inherit &deflambda
      extend class_extension(&deflambda)
    else # other Object
      (class << self; self; end).class_eval(&deflambda)
    end

    obj
  end

end
