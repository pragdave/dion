# ----
# Copyright (c) 2003, 2003 David Thomas (dba Thomas Consulting)
# All Rights Reserved.
# The right to use this software is granted by separate license
# between Destination Imagination, Inc and David Thomas.
#
# No part of this program may be reproduced, stored in a retrieval
# system, or transmitted, in any form, or by any means unless 
# explicitly permitted by the license.
# -----

module Html

  Required = "<span class=\"required\">(req'd)</span>"

  # Output the tag part of a two column prompt
  
  def Html.tag(text)
    %{<td class="formtag">#{text}:</td>}
  end

  def Html.value(text)
    %{<td class="formval">#{text}</td>}
  end

  # Help function to output a 2 column table entry

  def Html.echo2cols(c1, c2) 
    "<tr>" + tag(c1) + value(c2) + "</tr>"
  end

  # Output a hidden field

  def Html.echo_hidden(name, value)
    %{<input type="hidden" name="#{name}" value="#{value}">}
  end

  # Output an input field

  def Html.echo_input(name, value, size, max_size)
    %{<input type="text" name="#{name}" value="#{value}" 
      size="#{size}" maxsize="#{max_size}">}
  end


  # Output an input field in a table

  def Html.echo2input(label, name, value, size, max_size) 
    "<tr>" + tag(label) + %{<td><input type="text" name="#{name}" value="#{value}"
      size="#{size}" maxsize="#{max_size}"></td></tr>}
  end


  # Output a radio button

  def Html.echo_radio(name, value, options, add_dont_care=false, multiline=false)
    res = ""
    found_match = false
    options.each do |key, label|
      checked = ""
      if key == value
        checked = "checked"
        found_match = true
      end
      
      res << %{<label>
        <input type="radio" 
        name="#{name}" 
        value="#{key}" 
        #{checked}>
      }
      res << "#{label}</label>&nbsp;&nbsp;"
        
      res << "<br>" if multiline
      res
    end
  
    if add_dont_care
      checked = found_match ? "" : " checked"
      res << %{<label><input type="radio" name="#{name}" value="" #{checked}>
        "Don't care</label>}
    end
    res
  end

  # Return a string as an error message

  def Html.echo_error(msg)
    "<span class=\"error\">#{msg}</span>\n"
  end

  # Rturn a string as a Note message
  
  def Html.echo_note(msg) 
    "<span class=\"note\">#{msg}</span><p>"
  end
  
  
  ###################################################################
  #
  # This class lets us echo out form fields from the objects that
  # represent database tables. We prepend the prefix to each field name
  # because sometimes we'll have multiple copies of the same object
  # on a form
  
  
  class Echoer 
  
    def initialize(prefix, writer, values) 
      @prefix = prefix + "_"
      @writer = writer
      @values  = values
    end
    
    def simple_input(name, size, maxSize) 
      value = @values[name]
      echo Html.echo_input(field_name(name), value, size, maxSize)
    end
    
    def text_row(tag, name, size, maxSize, extra=nil)
      echo "<tr>"
      echo Html.tag(tag)
      echo "<td class=\"formval\">"
      simple_input(name, size, maxSize)
      echo "&nbsp;<span style=\"font-size: small; font-weight: normal\">#{extra}</span>" if extra
      echo "</td></tr>"
    end

    def heading(txt)
      display_raw("", "<h2>#{txt}</h2>")
    end

    def full_width(txt)
      echo "<tr><td colspan=\"2\">#{txt}</td></tr>\n"
    end

    def one_col(txt)
      echo "<tr><td></td><td>#{txt}</td></tr>\n"
    end

    def bool_row(tag, name) 
      value = @values[name]
      checked = (value == 'Y') ? " checked" : ""
      name = field_name(name)
      
      echo Html.echo2cols(tag,
                %{<input type="Checkbox" name="#{name}" value="Y"#{checked}>})
    end
    
    def radio(tag, name, options, add_dont_care=false, multiline=false) 
      value = @values[name]
      Html.echo2cols(tag, 
                     Html.echo_radio(field_name(name), value, options, add_dont_care, multiline))
    end
    
    def hidden(name)
      echo Html.echo_hidden(field_name(name), @values[name])
    end
    
    def display_raw(tag, value) 
      echo Html.echo2cols(tag, value)
    end
    
    def display(tag, name)
      display_raw(tag, @values[name])
    end
    
    # DDLB support
    def ddlb_start(tag, name)
      if tag
        @ddlb_value = @values[name]
        echo "<tr><td class=\"formtag\">#{tag}</td><td class=\"formval\">"
      end
      echo "<select name=\"#{field_name(name)}\">"
    end
    
    def ddlb_option(key, value)
      selected = (key == @ddlb_value) ? " selected" : ""
      echo "<option value=\"#{key}\"#{selected}>#{value}"
    end
    
    def ddlb_end
      echo "</select>"
    end

    def echo(*txt)
      txt.each {|t| @writer << t}
    end

    def field_name(name)
      @prefix + name.to_s
    end
  end

  # and this class lets us read values from a form back into the associative
  # array

  class FormGetter 

    def initialize(prefix, cgi)
      @prefix = prefix + "_"
    end

    def get(name) 
      fname = @prefix + name
      val = cgi[fname][0] || ""
      val.trim
    end

    def get_bool(name)
      get_name(name) == 'Y'
    end
  end
end

  
