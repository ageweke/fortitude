module Fortitude
  module TagStore
    def tag(name, options = nil)
      tag_object = nil
      modified = false
      name = Fortitude::Tag.normalize_tag_name(name)

      @_tags_by_name ||= { }

      unless options
        tag_object = @_tags_by_name[name] || tags[name].try(:dup)
        modified = true if tag_object
      end

      tag_object ||= Fortitude::Tag.new(name, options || { })

      @_tags_by_name[name] = tag_object

      if modified
        tags_changed!([ tag_object ])
      else
        tags_added!([ tag_object ])
      end
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

    def tags_changed!(tags)
      # nothing here
    end

    def delegate_tag_stores
      [ ]
    end
  end
end
