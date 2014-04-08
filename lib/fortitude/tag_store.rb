module Fortitude
  module TagStore
    def tag(name, options = { })
      new_tag = Fortitude::Tag.new(name, options)

      @_tags_by_name ||= { }
      @_tags_by_name[new_tag.name] = new_tag

      tags_added!([ new_tag ])
    end

    def tags
      out = { }
      (delegate_tag_stores || [ ]).each { |d| out.merge!(d.tags) }
      out.merge!(@_tags_by_name || { })
      out
    end

    def tags_added!(tags)
      # nothing here
    end

    def delegate_tag_stores
      [ ]
    end
  end
end
