module Fortitude
  module TagStore
    def tag(name, options = nil)
      @_tags_by_name ||= { }

      name = Fortitude::Tag.normalize_tag_name(name)
      tag_object = Fortitude::Tag.new(name, options || { })
      @_tags_by_name[name] = tag_object

      tags_added!([ tag_object ])
    end

    def modify_tag(name)
      name = Fortitude::Tag.normalize_tag_name(name)
      existing_tag = tags[name]

      unless existing_tag
        raise Fortitude::Errors::TagNotFound.new(self, name)
      end

      new_tag = existing_tag.dup
      yield new_tag
      @_tags_by_name ||= { }
      @_tags_by_name[name] = new_tag

      tags_changed!([ new_tag ])
    end

    def tags
      out = { }
      (delegate_tag_stores || [ ]).each { |d| out.merge!(d.tags) }
      out.merge!(@_tags_by_name || { })
      out
    end

    def tags_added!(tags)
      tags_changed!(tags)
    end

    def tags_changed!(tags)
      # nothing here
    end

    def delegate_tag_stores
      [ ]
    end
  end
end
