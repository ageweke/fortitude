require 'active_support/core_ext'

module Fortitude
  class AssignsProxy
    def initialize(widget, keys)
      @widget = widget
      @keys = { }
      keys.each { |k| @keys[k] = true }
    end

    def is_default?(x)
      !! @widget._fortitude_default_assigns[x.to_sym]
    end

    def keys
      @keys.keys
    end

    def has_key?(x)
      !! @keys[x.to_sym]
    end

    def [](x)
      if has_key?(x)
        ivar_name = @widget.class.instance_variable_name_for_need(x)
        @widget.instance_variable_get(ivar_name)
      end
    end

    def []=(x, y)
      if has_key?(x)
        ivar_name = @widget.class.instance_variable_name_for_need(x)
        @widget.instance_variable_set(ivar_name, y)
      end
    end

    def to_hash
      out = { }
      keys.each { |k| out[k] = self[k] }
      out
    end

    def to_h
      to_hash
    end

    def length
      @keys.length
    end

    def size
      @keys.size
    end

    def to_s
      "<Assigns for #{@widget}: #{to_hash}>"
    end

    def inspect
      "<Assigns for #{@widget}: #{to_hash.inspect}>"
    end

    def member?(x)
      has_key?(x)
    end

    def store(key, value)
      self[key] = value
    end

    delegate :==, :assoc, :each, :each_pair, :each_key, :each_value, :empty?, :eql?, :fetch, :flatten,
      :has_value?, :hash, :include?, :invert, :key, :key?, :merge, :rassoc, :reject, :select,
      :to_a, :value?, :values, :values_at, :to => :to_hash
  end
end
