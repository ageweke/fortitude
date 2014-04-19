package com.fortituderuby.ext.fortitude;

import java.lang.reflect.Field;
import java.io.IOException;
import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyModule;
import org.jruby.RubyNumeric;
import org.jruby.RubyObject;
import org.jruby.anno.JRubyClass;
import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.runtime.load.Library;

public class FortitudeNativeLibrary implements Library {
    public void load(Ruby runtime, boolean wrap) throws IOException {
        System.err.println("FortitudeNativeLibrary loaded!");

        RubyClass stringClass = runtime.getClass("String");
        stringClass.defineAnnotatedMethod(FortitudeStringExtensions.class, "fortitude_append_escaped_string");

        RubyClass hashClass = runtime.getClass("Hash");
        hashClass.defineAnnotatedMethod(FortitudeHashExtensions.class, "fortitude_append_as_attributes");
    }

    public static class FortitudeStringExtensions {
        @JRubyMethod(name = "fortitude_append_escaped_string")
        public static IRubyObject fortitude_append_escaped_string(ThreadContext context, IRubyObject self, IRubyObject output) {
            System.err.println("fortitude_append_escaped_string called!");
            return null;
        }
    }

    public static class FortitudeHashExtensions {
        @JRubyMethod(name = "fortitude_append_as_attributes")
        public static IRubyObject fortitude_append_as_attributes(ThreadContext context, IRubyObject self, IRubyObject output, IRubyObject prefix) {
            System.err.println("fortitude_append_as_attributes called!");
            return null;
        }
    }
}
