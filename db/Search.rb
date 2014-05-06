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

require 'web/Html'
require 'db/TableDefinitions'

class Search

  ComparisonName = {
    :EQUALS   => ' is',
    :FLEQUALS => ' is',
    :LIKE     => ' starts',
    :CONTAINS => ' contains',
    :DAYS_OLD => " in last",
    :ISNULL   => ' is',
    :ROLE     => '',
    :ISA      => '',
  }







  def initialize(session, field_list, joins, base_table, extra_tables)
    @field_list = deep_copy(field_list)
    @session = session
    @joins = joins
    @base_table = base_table
    @extra_tables = extra_tables

    @cgi = session.cgi
    @value_table = {}

    @ordered_names = @field_list.keys.sort do |a,b|
      @field_list[a][:order] <=> @field_list[b][:order] 
    end

    @field_list.each do |name, attrs|
      value = get_form_field(name)
      @value_table[name] = value unless value.empty?
    end
  end

  def deep_copy(field_list)
    result = {}
    field_list.each_key {|k| result[k] = field_list[k].dup }
    result
  end

  # Fix the value of the specified field. This means that the user
  #  will not be allowed to change it.

  def fix_field(field, value) 
    set_field(field, :fixed, true);
    set_default(field, value);
  end

  # Set a default value into a specified field 
  def set_default(field, value) 
    @value_table[field] = value
  end



  # Set the list of fields to be displayed. 
  
  def display_fields(*list)
    list.each { |field| set_field(field, :display, true) }
  end

  # Shortcut to display all fields
  def display_all_fields
    @field_list.each do |field, attrs|
      set_field(field, :display, true) unless attrs[:comp] == :ISNULL
    end
  end

  # Shortcut to display all fields
  def display_all_fields_except(*list)
    display_all_fields
    list.each { |field| set_field(field, :display, false) }
  end

  # Hide a particular field
  def hide_field(field)
    set_field(field, :display, false)
  end

  # Generate the form. We only display fields which are marked
  #  'display', and only provide input areas if they're not marked
  #  'fixed'. Fixed, non-display fields are added as hidden fields
  
  def to_form(target,
              make_form = true,
              button="List matching TeamPaks",
              top_title = nil)
    
    
    #     $this->dump("toForm");
    
    # Create a separate table of the values - Echor doesn't know
    # about our $fields structure
    
    @html = ""
    
    e = Html::Echoer.new("QRY", @html, @value_table)
    
    echo top_title if top_title
    
    if (make_form)
      echo %{<form action="#{target}" method="POST"><table>\n}
    end
    
    if top_title
      echo "<tr><td></td><td><input type=\"submit\" name=\"criteria\" value=\"#{button}\"></td></tr>"
    end

    @ordered_names.each do |name|

      attrs = @field_list[name]


      # Section breaks are always shown

      if attrs[:break]
        echo "<tr><td>&nbsp;</td></tr>"
        echo %{<tr><td colspan="2" style="font-size: small"><b>#{attrs[:break]}</b></td></tr>}
        next
      end
      
    
      # If need is set, then it names another variable thata must be
      # set fot this field to be valid

      needs = attrs[:needs]
      next if needs && !@value_table[needs]
      next unless attrs[:label]

      if attrs[:display]

        prompt = attrs[:label] + ComparisonName[attrs[:comp]]

        radio = attrs[:radio]
        ddlb  = attrs[:ddlb]
        checkbox = attrs[:comp] == :ISA

        if attrs[:fixed]
          if radio
            e.display_raw(prompt, radio[@value_table[name]])
          elsif ddlb
            e.display_raw(prompt, ddlb_name_for_value(attrs, @value_table[name]))
          else
            e.display(prompt, @value_table[name])
          end
        else 
          if radio
            e.radio(prompt, name, radio, true)
          elsif ddlb
            display_DDLB(e, name, attrs)
          elsif checkbox
            if attrs[:isa_options]
              echo "<tr>"
              echo Html.tag(prompt)
              echo "<td>"
              echo %{<input type="Checkbox" name="#{e.field_name(name)}" value="Y">}
              echo attrs[:isa_options_label]
              display_DDLB(e, name, attrs, false)
              echo "</tr></tr>"
            else
              e.bool_row(prompt, name)
            end
          else 
            prefix = attrs[:prefix]
            if prefix
              echo "<tr><td class=\"formtag\">#{prompt}:</td><td class=\"formval\">"
              if @field_list[prefix][:fixed]
                echo "<b>#{@value_table[prefix]}</b>"
              else
                e.simple_input(prefix, 3, 3)
              end
              echo "-"
              e.simple_input(name, 17, 100)
              echo "</td></tr>\n"
            else 
              if attrs[:comp] == :DAYS_OLD
                e.text_row(prompt, name, 5, 5, "days")
              else
                e.text_row(prompt, name, 20, 100)
              end
            end
          end
        end
      end
      if attrs[:fixed]
        e.hidden(name)
      end
    end
    
    echo %{<tr><td>&nbsp;</td></tr><tr><td></td><td>} 
    echo %{<input type="submit" name="criteria" value="#{button}">}
      
      
      echo "</td></tr>\n"
      
      if make_form
        echo "</table></form>"
      end

      @html
    end
    
  # Return the value of a field on the current form *

  def get_form_field(name) 
    form_name = form_name_of(name)
    (@cgi[form_name_of(name)] || "").strip
  end

  alias :[] :get_form_field

  # Build a query string given the form variables resulting
  # from the above. Return list(where, tables)

  def build_query
    
    tables = { @base_table => 1}
    wheres = []

    isa_list = []

    #       $this->dump("buildQuery");
   
    @field_list.each do |name, attrs|

      value = get_form_field(name)

      # If there's a value, we need to generate a 'where' clause
      unless value.empty?
        table = attrs[:table]
        tables[table] = 1  unless attrs[:comp] == :ROLE

        col_name = name.to_s

        case attrs[:comp]

        when :CONTAINS
          wheres << "#{col_name} ILIKE #{$store.quote('%' + value + '%')}"

        when :LIKE
          wheres << "#{col_name} ILIKE '#{$store.quote(value + '%')}"

        when :EQUALS
          wheres << "#{col_name} = #{$store.quote(value)}"

        when :FLEQUALS
          amt = (Float(value) rescue nil)
          if amt
            wheres << "#{col_name} = '#{amt}'"
          end

        when :ISNULL
          wheres << "#{col_name} is NULL"

        when :DAYS_OLD
          age = (Integer(value) rescue 0)
          wheres << "age(#{col_name}) <= interval '#{value} days'"

        when :ROLE
          final_value = value
          if attrs[:role_lookup]
            final_value = send(attrs[:role_lookup], value)
            unless final_value
              raise "#{attrs[:label]} '#{value}' not found"
            end
          end
          or_clause = ""
          if name == :role_affiliate
            or_clause = "or role_affiliate=#{final_value}"
          elsif name == :role_region
            or_clause = "or role_region=#{final_value}"
          end

          if final_value == "NONE"
            sql = "not " 
          else
            sql = ""
          end

          sql << "exists (select 1 from role where role_user=user_id and " +
            "((role_target_type=#{attrs[:role_target_type]} "

          unless value == "NONE"
            sql << "and role_target=#{final_value}"
          end
          sql << ") #{or_clause}))"

          wheres << sql

        when :ISA
          opt = get_form_field("options_" + name.to_s)
          extra = ""
          role_tables = [ "role" ]

          if opt && !opt.empty?
            extra = " and role_target_type=#{attrs[:role_target]} #{attrs[:isa_join]}"
            extra = extra.sub(/\?/, opt)
            if attrs[:isa_extra_tables]
              role_tables << attrs[:isa_extra_tables]
            end
          end


          isa_list << "(exists (select 1 " +
            "from #{role_tables.join(',')} where role_user=user_id and " +
            "role_name=#{attrs[:role_name]}#{extra}))"
        else
          fail "Invalid comparison type: #{attrs[:comp]}"
        end
      end

    end

    # add the join clauses - currently only one level deep

    @extra_tables.each do |leaf_table, extras|
      if tables[leaf_table]
        extras.each {|e| tables[e] = 1 }
      end
    end

    tables.each_key do |key|

      join = @joins[key]
      if join
#        if pre = Prefixes[key]
#          join = pre + "." + join
#        end
        wheres << join
      end
    end

    table_list = tables.keys

    # Convert the where clauses into a nice list
    where_clause = wheres.join(" and ")

    unless isa_list.empty?
      isa_clause = isa_list.join(" or ")
      if where_clause.empty?
        where_clause = isa_clause
      else
        where_clause = "#{where_clause} and (#{isa_clause})"
      end
    end

    where_clause = "1=1 " if where_clause.empty?
$stderr.puts where_clause

$stderr.puts table_list

    return where_clause, table_list
  end


  private

  def echo(txt)
    @html << txt
  end

  def <<(txt)
    @html << txt
  end

  # Check a name is valid and set its content 
  def set_field(name, attr, value) 
    field = @field_list[name]
    fail "Bad name '#{name}' in MemberSearch" unless field
    field[attr] = value
  end

  def form_name_of(name)
    "QRY_" + name.to_s
  end

  # Populate a drop-down listbox from values
  # in the database

  def display_DDLB(e, name, attrs, show_prompt=true)
    if show_prompt
      e.ddlb_start(attrs[:label], name)
      e.ddlb_option("", "&nbsp;&nbsp;[don't care]&nbsp;&nbsp;")
    else
      e.ddlb_start(nil, "options_" + name.to_s)
      e.ddlb_option("", "&nbsp;&nbsp;[all]&nbsp;&nbsp;")
    end

    if attrs[:allow_none]
      e.ddlb_option("NONE", "NONE")
    end

    rows = ddlb_query(attrs)

    rows.each do |row|
      e.ddlb_option(row[0], row[1])
    end

    e.ddlb_end
  end


  # Given the value that would have been displayed in a ddlb, return
  # the corresponding name
  def ddlb_name_for_value(attrs, value)
    return "NONE" if value == "NONE"
    rows = ddlb_query(attrs)
    rows.each do |row|
      if row[0] == value
        return row[1]
      end
    end
    return "Unknown"
  end


  def ddlb_query(attrs)
    query = attrs[:ddlb] || attrs[:isa_options]

    return query if query.kind_of? Array

    # If there's :needs attribute, we assume it's a variable that
    # we'll be substituting into the SQL query

    needs = attrs[:needs]
    if needs
      query = query.sub(/!#{needs}!/, @value_table[needs].to_s)
    end
    
    $store.raw_select(query)
  end
end
