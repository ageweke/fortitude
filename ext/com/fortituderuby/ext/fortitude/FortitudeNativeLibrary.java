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
        public static final int BUFFER_SIZE = 256;
        public static final int MAX_SUBSTITUTION_LENGTH = 6;

        public static final byte AMPERSAND_BYTE = (byte) '&';
        public static final byte LESS_THAN_BYTE = (byte) '<';
        public static final byte GREATER_THAN_BYTE = (byte) '>';
        public static final byte SINGLE_QUOTE_BYTE = (byte) '\'';
        public static final byte DOUBLE_QUOTE_BYTE = (byte) '\"';

        @JRubyMethod(name = "fortitude_append_escaped_string")
        public static IRubyObject fortitude_append_escaped_string(ThreadContext context, IRubyObject self, IRubyObject output) {
            RubyString selfString = (RubyString) self;
            RubyString outputString = (RubyString) output;

            byte[] selfBytes = selfString.getBytes();

            byte[] buffer = new byte[BUFFER_SIZE];
            int bufferPos = 0;

            for (int i = 0; i < selfBytes.length; ++i) {
                if (bufferPos > (BUFFER_SIZE - MAX_SUBSTITUTION_LENGTH)) {
                    outputString.cat(buffer, 0, bufferPos);
                    bufferPos = 0;
                }

                byte sourceByte = selfBytes[i];

                switch(sourceByte) {
                case AMPERSAND_BYTE:
                    buffer[bufferPos++] = '&';
                    buffer[bufferPos++] = 'a';
                    buffer[bufferPos++] = 'm';
                    buffer[bufferPos++] = 'p';
                    buffer[bufferPos++] = ';';
                    break;

                case LESS_THAN_BYTE:
                    buffer[bufferPos++] = '&';
                    buffer[bufferPos++] = 'l';
                    buffer[bufferPos++] = 't';
                    buffer[bufferPos++] = ';';
                    break;

                case GREATER_THAN_BYTE:
                    buffer[bufferPos++] = '&';
                    buffer[bufferPos++] = 'g';
                    buffer[bufferPos++] = 't';
                    buffer[bufferPos++] = ';';
                    break;

                case SINGLE_QUOTE_BYTE:
                    buffer[bufferPos++] = '&';
                    buffer[bufferPos++] = '#';
                    buffer[bufferPos++] = '3';
                    buffer[bufferPos++] = '9';
                    buffer[bufferPos++] = ';';
                    break;

                case DOUBLE_QUOTE_BYTE:
                    buffer[bufferPos++] = '&';
                    buffer[bufferPos++] = '#';
                    buffer[bufferPos++] = 'q';
                    buffer[bufferPos++] = 'u';
                    buffer[bufferPos++] = 'o';
                    buffer[bufferPos++] = 't';
                    buffer[bufferPos++] = ';';
                    break;
                }
            }

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
