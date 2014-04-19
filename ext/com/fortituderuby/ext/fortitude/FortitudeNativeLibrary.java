package com.fortituderuby.ext.fortitude;

import java.lang.reflect.Field;
import java.io.IOException;
import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyModule;
import org.jruby.RubyNumeric;
import org.jruby.RubyObject;
import org.jruby.RubyString;
import org.jruby.anno.JRubyClass;
import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.runtime.load.Library;

public class FortitudeNativeLibrary implements Library {
    static Ruby runtime;

    public void load(Ruby theRuntime, boolean wrap) throws IOException {
        System.err.println("FortitudeNativeLibrary loaded!");

        runtime = theRuntime;

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
            if (! (output instanceof RubyString)) {
                throw new RuntimeException("fail");
            }

            RubyString selfString = (RubyString) self;
            RubyString outputString = (RubyString) output;

            IRubyObject htmlSafe = selfString.getInstanceVariable("@html_safe");
            if (htmlSafe != null && htmlSafe.isTrue()) {
                outputString.cat(selfString);
            } else {
                byte[] selfBytes = selfString.getBytes();
                fortitude_escaped_strcpy(outputString, selfBytes);
            }

            return runtime.getNil();
        }

        public static void fortitude_escaped_strcpy(RubyString output, byte[] source) {
            byte[] buffer = new byte[BUFFER_SIZE];
            int bufferPos = 0;

            for (int i = 0; i < source.length; ++i) {
                if (bufferPos > (BUFFER_SIZE - MAX_SUBSTITUTION_LENGTH)) {
                    output.cat(buffer, 0, bufferPos);
                    bufferPos = 0;
                }

                byte sourceByte = source[i];

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
                    buffer[bufferPos++] = 'q';
                    buffer[bufferPos++] = 'u';
                    buffer[bufferPos++] = 'o';
                    buffer[bufferPos++] = 't';
                    buffer[bufferPos++] = ';';
                    break;

                default:
                    buffer[bufferPos++] = sourceByte;
                    break;
                }
            }

            if (bufferPos > 0) {
                output.cat(buffer, 0, bufferPos);
            }
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
