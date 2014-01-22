#include "ruby.h"

void Init_fortitude_native_ext();

// VALUE method_insert_element(VALUE self, VALUE rb_output, VALUE rb_name, VALUE rb_attributes);
VALUE method_append_escaped_string(VALUE self, VALUE rb_output);

void Init_fortitude_native_ext() {
    VALUE string_class = rb_const_get(rb_cObject, rb_intern("String"));

    rb_define_method(string_class, "fortitude_append_escaped_string", method_append_escaped_string, 1);
}

#define BUF_SIZE 256
#define MAX_SUBSTITUTION_LENGTH 6

VALUE method_append_escaped_string(VALUE self, VALUE rb_output) {
    char buf[BUF_SIZE + 1];
    const char* c_self = RSTRING_PTR(self);
    VALUE html_safe = rb_iv_get(self, "@html_safe");

    if (RTEST(html_safe)) {
        rb_str_cat2(rb_output, c_self);
        return Qnil;
    }

    const char* input_pos = c_self;
    char* buf_pos = buf;
    int buf_offset = 0;

    while (1) {
        if (buf_offset >= (BUF_SIZE - MAX_SUBSTITUTION_LENGTH)) {
            *buf_pos = '\0';
            rb_str_cat2(rb_output, buf);
            buf_pos = buf;
            buf_offset = 0;
        }

        char ch = *input_pos;

        if (ch == '&') {
            *buf_pos++ = '&';
            *buf_pos++ = 'a';
            *buf_pos++ = 'm';
            *buf_pos++ = 'p';
            *buf_pos++ = ';';

            buf_offset += 5;
        } else if (ch == '<') {
            *buf_pos++ = '&';
            *buf_pos++ = 'l';
            *buf_pos++ = 't';
            *buf_pos++ = ';';

            buf_offset += 4;
        } else if (ch == '>') {
            *buf_pos++ = '&';
            *buf_pos++ = 'g';
            *buf_pos++ = 't';
            *buf_pos++ = ';';

            buf_offset += 4;
        } else if (ch == '"') {
            *buf_pos++ = '&';
            *buf_pos++ = 'q';
            *buf_pos++ = 'u';
            *buf_pos++ = 'o';
            *buf_pos++ = 't';
            *buf_pos++ = ';';

            buf_offset += 6;
        } else {
            if (ch == '\0') {
                break;
            }

            *buf_pos++ = ch;
            buf_offset += 1;
        }

        input_pos++;
    }

    if (buf_offset > 0) {
        *buf_pos = '\0';
        rb_str_cat2(rb_output, buf);
    }

    return Qnil;
}

// int append_hash_attributes(VALUE key, VALUE val, VALUE current_output) {
//     static char buf[100];

//     char *c_key, *c_value;

//     sprintf(buf, " %s=\"%s\"", RSTRING_PTR(key), RSTRING_PTR(val));
//     rb_str_cat2(current_output, buf);

//     return ST_CONTINUE;
// }

// VALUE method_insert_element(VALUE self, VALUE rb_output, VALUE rb_name, VALUE rb_attributes) {
//     char* c_name = RSTRING_PTR(rb_name);

//     static char buf[100];

//     switch(TYPE(rb_attributes)) {
//         case T_STRING:
//             sprintf(buf, "<%s>", c_name);
//             rb_str_cat2(rb_output, buf);

//             rb_str_append(rb_output, rb_attributes);

//             sprintf(buf, "</%s>", c_name);
//             rb_str_cat2(rb_output, buf);
//         break;

//         case T_HASH:
//             sprintf(buf, "<%s ", c_name);
//             rb_str_cat2(rb_output, buf);

//             // fprintf(stderr, "About to append attributes...");

//             // rb_hash_foreach(rb_attributes, append_hash_attributes, rb_output);

//             // fprintf(stderr, "...appended attributes.");

//             if (rb_block_given_p()) {
//                 rb_str_cat2(rb_output, ">");

//                 rb_yield(Qnil);

//                 sprintf(buf, "</%s>", c_name);
//                 rb_str_cat2(rb_output, buf);
//             } else {
//                 rb_str_cat2(rb_output, "/>");
//                 sprintf(buf, ">");
//             }
//         break;

//         case T_NIL:
//             if (rb_block_given_p()) {
//                 sprintf(buf, "<%s>", c_name);
//                 rb_str_cat2(rb_output, buf);

//                 rb_yield(Qnil);

//                 sprintf(buf, "</%s>", c_name);
//                 rb_str_cat2(rb_output, buf);
//             } else {
//                 sprintf(buf, "<%s/>", c_name);
//                 rb_str_cat2(rb_output, buf);
//             }
//         break;

//         default:
//             /* raise */
//         break;
//     }

//     return Qnil;
// }

// /*
//       def #{element_name}(attributes = nil)
//         o = @output

//         if (! attributes)
//           if block_given?
//             o << FAST_ELEMENT_#{element_name.upcase}_OPEN
//             yield
//             o << FAST_ELEMENT_#{element_name.upcase}_CLOSE
//           else
//             o << FAST_ELEMENT_#{element_name.upcase}_ALONE
//           end
//         elsif attributes.kind_of?(String)
//           o << FAST_ELEMENT_#{element_name.upcase}_OPEN
//           o << attributes
//           o << FAST_ELEMENT_#{element_name.upcase}_CLOSE
//         else
//           o << FAST_ELEMENT_#{element_name.upcase}_PARTIAL_OPEN
//           _attributes(attributes)

//           if block_given?
//             o << FAST_ELEMENT_PARTIAL_OPEN_END
//             yield
//             o << FAST_ELEMENT_#{element_name.upcase}_CLOSE
//           else
//             o << FAST_ELEMENT_PARTIAL_OPEN_ALONE_END
//           end
//         end
//       end

// */
