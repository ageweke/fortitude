module Fortitude
  module TagStore
    def tag(name, options = { })
      new_tag = Fortitude::Tag.new(name, options)

      @_tag_store ||= { }
      @_tag_store[new_tag.name] = new_tag

      tags_added!([ new_tag ])
    end

    def tags
      out = (@_tag_store || { })
      out.merge!(superclass.tags) if superclass.respond_to?(:tags)
      out
    end

    def add_tags_from!(other_store)
      added = [ ]
      @_tag_store ||= { }

      other_store.tags.each do |name, tag_object|
        if tag_object != @_tag_store[name]
          @_tag_store[name] = tag_object
          added << tag_object
        end
      end

      tags_added!(added)
    end

    def tags_added!(tags)
      # nothing here
    end
  end
end
