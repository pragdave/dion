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

require 'dbi'

class User
  attr_accessor :contact
  attr_accessor :affiliate
  def to_s
    @contact.to_s
    puts @affiliate
    puts "==========="
  end

  def ==(other)
    if @affiliate != other.affiliate
      puts "Bad affiliate"
    else
      contact == other.contact
    end
  end

  def dump_to(file)
    @contact.dump_to(file)
    file.puts %{
insert into user_table(user_id, user_password, user_contact,
user_affiliate) values(nextval('user_table_user_id_seq'), '!', 
currval('contact_con_id_seq'), #@affiliate);
}
file.puts %{
insert into role(role_id,role_user,role_affiliate,role_region,role_name,
role_target_type,role_target) values(nextval('role_role_id_seq'),
currval('user_table_user_id_seq'), #{@affiliate}, null, 3, null,null);}
file.puts %{
insert into role(role_id,role_user,role_affiliate,role_region,role_name,
role_target_type,role_target) values(nextval('role_role_id_seq'),
currval('user_table_user_id_seq'), #{@affiliate}, null, 10, null,null);}
  end
end

class Contact
  attr_accessor :con_first_name, :con_last_name
  attr_accessor :con_ship, :con_mail
  attr_accessor :con_day_tel, :con_eve_tel, :con_fax_tel
  attr_accessor :con_email

  def to_s
    puts @con_email
    puts @con_first_name + " " + @con_last_name
    puts @con_day_tel, @con_eve_tel, @con_fax_tel
  end

  def ==(other)
    if @con_first_name != other.con_first_name
      puts "Bad first name"
    elsif @con_last_name != other.con_last_name
      puts "Bad last name"
    elsif @con_day_tel != other.con_day_tel
      puts "Bad day tel"
    elsif @con_eve_tel != other.con_eve_tel
      puts "Bad eve tel"
    elsif @con_fax_tel != other.con_fax_tel
      puts "Bad fax tel"
    else
      true
    end
  end

  def sql_string(v)
    if !v || v.empty?
      "null"
    else
      "'" + v.gsub(/'/, "''")+ "'"
    end
  end

  def strings(*vals)
    vals.map{|v| sql_string(v)}.join(", ")
  end

  def dump_to(file)
    sql = %{

insert into contact(con_id, con_first_name, con_last_name,
con_day_tel, con_eve_tel, con_fax_tel, con_email, con_ship_to_mail)
values(nextval('contact_con_id_seq'), }
    sql << strings(@con_first_name, @con_last_name, @con_day_tel,
                   @con_eve_tel, @con_fax_tel, @con_email, 'false')
    sql << ");"
    file.puts sql
  end
end

class Address
  attr_accessor :add_line1, :add_line2, :add_city, :add_county
  attr_accessor :add_state, :add_zip, :add_country

  attr_accessor :int1, :int2

  def normalize(row)
    @add_country = 'U.S.A.' if @add_country.empty?

    unless @int1.empty? && @int2.empty?
      p self
      exit
    end
  end
end

class Affiliates
  def initialize
    @affs = {}
    $db.select_all("select aff_id, aff_passport_prefix from affiliate") do |r|
      @affs[r[1].to_i] = r[0]
    end
  end

  def find(prefix)
    @affs[prefix.to_i]
  end
      
end



def dump(u)
  u.each  {|uu| uu.dump_to($rejects) }
end

def check(u)
  users = u.dup
  first = users.shift

  users.each do |other|
    unless other == first
      dump(u) 
      return false
    end
  end
  true
end

users = {}

$db = DBI.connect("DBI:Pg:test", "dave", "")
$rejects = File.open("rejects.sql", "w")
$imports = File.open("import.sql", "w")

affiliates = Affiliates.new


count = 0
rejects = 0
ok = 0

puts "Cheating with prefix"

$db.select_all("select * from marita_people where " +
           "con_email is not null and con_first_name is not null and " +
           "con_last_name is not null and passport_prefix is not null") do |row|
    count += 1

  email = row['con_email'].downcase

  c = Contact.new
  c.con_first_name = row['con_first_name']
  c.con_last_name = row['con_last_name']
  c.con_ship = c.con_mail = nil
  c.con_day_tel = row['con_work_phone']
  c.con_eve_tel = row['con_home_phone']
  c.con_fax_tel = row['con_fax_phone']
  c.con_email = email

  u = User.new
  u.contact = c

  prefix = row['passport_prefix']

prefix=750
  aff_id = affiliates.find(prefix)

  if aff_id
    u.affiliate = aff_id
    users[email] ||= []
    users[email] << u
  else
    rejects += 1
    puts "Skipping unknown aff prefix #{prefix}"
  end
end

users.each do |email, u|
  if u.size == 1 || check(u)
    u[0].dump_to($imports)
    ok += 1
  else
    rejects += 1
  end
end

puts "OK: #{ok}, Rejects: #{rejects}"
