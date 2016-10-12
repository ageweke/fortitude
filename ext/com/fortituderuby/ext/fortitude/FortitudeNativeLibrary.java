package com.fortituderuby.ext.fortitude;

import java.io.IOException;
import org.jruby.Ruby;
import org.jruby.RubyBasicObject;
import org.jruby.RubyBoolean;
import org.jruby.RubyArray;
import org.jruby.RubyClass;
import org.jruby.RubyFixnum;
import org.jruby.RubyHash;
import org.jruby.RubyNil;
import org.jruby.RubyString;
import org.jruby.RubySymbol;
import org.jruby.anno.JRubyClass;
import org.jruby.anno.JRubyMethod;
import org.jruby.exceptions.RaiseException;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.runtime.load.Library;

public class FortitudeNativeLibrary implements Library {
    public static final int BUFFER_SIZE = 256;

    static Ruby runtime;

    public void load(Ruby theRuntime, boolean wrap) throws IOException {
        runtime = theRuntime;

        RubyClass stringClass = runtime.getClass("String");
        stringClass.defineAnnotatedMethod(FortitudeStringExtensions.class, "fortitude_append_escaped_string");

        RubyClass hashClass = runtime.getClass("Hash");
        hashClass.defineAnnotatedMethod(FortitudeHashExtensions.class, "fortitude_append_as_attributes");
    }

    public static class FortitudeStringExtensions {
        public static final int MAX_SUBSTITUTION_LENGTH = 6;

        public static final byte AMPERSAND_BYTE = (byte) '&';
        public static final byte LESS_THAN_BYTE = (byte) '<';
        public static final byte GREATER_THAN_BYTE = (byte) '>';
        public static final byte SINGLE_QUOTE_BYTE = (byte) '\'';
        public static final byte DOUBLE_QUOTE_BYTE = (byte) '\"';

        @JRubyMethod(name = "fortitude_append_escaped_string")
        public static IRubyObject fortitude_append_escaped_string(ThreadContext context, IRubyObject self, IRubyObject output) {
            if (! (output instanceof RubyString)) {
                RaiseException exception = runtime.newArgumentError("You can only append to a String (this is a native (Java) method)");
                throw exception;
            }

            RubyString selfString = (RubyString) self;
            RubyString outputString = (RubyString) output;

            IRubyObject htmlSafe = selfString.getInstanceVariable("@html_safe");
            if (htmlSafe != null && htmlSafe.isTrue()) {
                outputString.cat(selfString);
            } else {
                byte[] selfBytes = selfString.getBytes();
                fortitude_escaped_strcpy(outputString, selfBytes, false);
            }

            return runtime.getNil();
        }

        public static void fortitude_escaped_strcpy(RubyString output, byte[] source, boolean forAttributeValue) {
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

                case DOUBLE_QUOTE_BYTE:
                    buffer[bufferPos++] = '&';
                    buffer[bufferPos++] = 'q';
                    buffer[bufferPos++] = 'u';
                    buffer[bufferPos++] = 'o';
                    buffer[bufferPos++] = 't';
                    buffer[bufferPos++] = ';';
                    break;

                case LESS_THAN_BYTE:
                    if (forAttributeValue) {
                        buffer[bufferPos++] = '<';
                    } else {
                        buffer[bufferPos++] = '&';
                        buffer[bufferPos++] = 'l';
                        buffer[bufferPos++] = 't';
                        buffer[bufferPos++] = ';';
                    }
                    break;

                case GREATER_THAN_BYTE:
                    if (forAttributeValue) {
                        buffer[bufferPos++] = '>';
                    } else {
                        buffer[bufferPos++] = '&';
                        buffer[bufferPos++] = 'g';
                        buffer[bufferPos++] = 't';
                        buffer[bufferPos++] = ';';
                    }
                    break;

                case SINGLE_QUOTE_BYTE:
                    if (forAttributeValue) {
                        buffer[bufferPos++] = '\'';
                    } else {
                        buffer[bufferPos++] = '&';
                        buffer[bufferPos++] = '#';
                        buffer[bufferPos++] = '3';
                        buffer[bufferPos++] = '9';
                        buffer[bufferPos++] = ';';
                    }
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
        public static final byte SPACE = (byte) ' ';

        public static void fortitude_append_to(IRubyObject object, RubyString rbOutput, boolean forAttributeValue) {
            if (object instanceof RubyString) {
                FortitudeStringExtensions.fortitude_escaped_strcpy(rbOutput, ((RubyString) object).getBytes(), forAttributeValue);
            } else if (object instanceof RubySymbol) {
                FortitudeStringExtensions.fortitude_escaped_strcpy(rbOutput, ((RubyString) ((RubySymbol) object).to_s()).getBytes(), forAttributeValue);
            } else if (object instanceof RubyArray) {
                RubyArray array = (RubyArray) object;

                for (int i = 0; i < array.getLength(); ++i) {
                    IRubyObject element = (IRubyObject) array.entry(i);
                    if (i > 0) {
                        rbOutput.cat(SPACE);
                    }
                    fortitude_append_to(element, rbOutput, forAttributeValue);
                }
            } else if (object instanceof RubyNil) {
                // nothing here
            } else if (object instanceof RubyFixnum) {
                RubyString asString = ((RubyFixnum) object).to_s();
                FortitudeStringExtensions.fortitude_escaped_strcpy(rbOutput, asString.getBytes(), forAttributeValue);
            } else {
                RubyString asString = (RubyString) ((RubyBasicObject) object).callMethod("to_s");
                FortitudeStringExtensions.fortitude_escaped_strcpy(rbOutput, asString.getBytes(), forAttributeValue);
            }
        }

        public static class AppendKeyAndValueVisitor extends RubyHash.Visitor {
            public final ThreadContext threadContext;
            public final RubyString prefix;
            public final RubyString output;
            public final RubyBoolean allowsBareAttributes;

            public static final byte[] EQUALS_QUOTE = new byte[] { (byte) '=', (byte) '"' };

            public AppendKeyAndValueVisitor(ThreadContext threadContext, RubyString prefix, RubyString output, RubyBoolean allowsBareAttributes) {
                this.threadContext = threadContext;
                this.prefix = prefix;
                this.output = output;
                this.allowsBareAttributes = allowsBareAttributes;
            }

            public void visit(IRubyObject key, IRubyObject value) {
                if (value instanceof RubyHash) {
                    RubyString newPrefix;

                    if (prefix != null) {
                        newPrefix = (RubyString) prefix.dup();
                        fortitude_append_to(key, newPrefix, false);
                    } else {
                        newPrefix = RubyString.newEmptyString(runtime);
                        fortitude_append_to(key, newPrefix, false);
                    }

                    newPrefix.cat('-');
                    fortitude_append_as_attributes(threadContext, value, output, newPrefix, this.allowsBareAttributes);
                } else if ((value instanceof RubyNil) || ((value instanceof RubyBoolean) && (! value.isTrue()))) {
                    // nothing here
                } else {
                    output.cat(' ');

                    if (prefix != null) {
                        output.cat(prefix);
                    } else {
                        // nothing here
                    }

                    fortitude_append_to(key, output, false);

                    if ((value instanceof RubyBoolean) && (value.isTrue())) {
                        if (this.allowsBareAttributes.isTrue()) {
                            // ok, nothing here
                        } else {
                            output.cat(EQUALS_QUOTE);
                            fortitude_append_to(key, output, false);
                            output.cat('"');
                        }
                    } else {
                        output.cat(EQUALS_QUOTE);
                        fortitude_append_to(value, output, true);
                        output.cat('"');
                    }
                }
            }
        }

        @JRubyMethod(name = "fortitude_append_as_attributes")
        public static IRubyObject fortitude_append_as_attributes(ThreadContext context, IRubyObject self, IRubyObject output, IRubyObject prefix, IRubyObject allowsBareAttributes) {
            if (! (output instanceof RubyString)) {
                RaiseException exception = runtime.newArgumentError("You can only append to a String (this is a native (Java) method)");
                throw exception;
            }
            if (prefix instanceof RubyNil) {
                prefix = null;
            }
            if (prefix != null && (! (prefix instanceof RubyString))) {
                RaiseException exception = runtime.newArgumentError("You can only use a prefix that is a String (this is a native (Java) method)");
                throw exception;
            }

            AppendKeyAndValueVisitor visitor = new AppendKeyAndValueVisitor(context, (RubyString) prefix, (RubyString) output, (RubyBoolean) allowsBareAttributes);

            ((RubyHash) self).visitAll(visitor);

            return runtime.getNil();
        }
    }
}
