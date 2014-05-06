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

require "bo/BusinessObject"
require "bo/Contact"
require "bo/Role"
require "bo/UserHistory"
require "util/Mailer"
require "util/Passphrase"
require 'errors/DionException'

class User < BusinessObject

  # Levels of access

#  NORMAL = 1
#  RD     = 11
#  AD     = 21
#  HQ     = 31


  def User.login(name, password)
    name = name.downcase
    u = User.with_name(name) || User.with_email(name)

    return nil unless u && u.user_password == User.crypt(password)
    u
  end

  def User.with_name(name)
    return nil if name.nil?
    name = name.downcase
    maybe_return($store.select_one(UserTable,
                                   "user_acc_name=?",
                                   name))
  end

  def User.with_email(email)
    return nil if !email || email.empty?
    rows = $store.select_complex(UserTable,
                                [ ContactTable ],
                                "user_contact=con_id and con_email ilike ?",
                                email)
    return nil if !rows || rows.empty?
    new(rows[0])
  end

  def User.with_id(user_id)
    maybe_return($store.select_one(UserTable, "user_id=?", user_id))
  end


  # Return a list of users given the results of a UserSearch
  def User.list_from_user_search(where, tables, limit=20)
    tables = tables.reject {|t| t == UserTable}
    $stderr.puts "USER:"
    $stderr.puts where
    $stderr.puts tables.join(", ")
    res = $store.select_complex(UserTable,
                                tables,
                                where)
    res.map {|m| new(m) }
  end


  ######################################################################
  # count the users (optionally qualified by an affiliate)
  def User.count_users(aff_id)
    sql = "select count(*) from user_table "
    params = []
    if aff_id
      sql << "where user_affiliate=?"
      params << aff_id
    end
    res = $store.raw_select(sql, *params)
    res[0][0]
  end

  ######################################################################
  # count the users by affiliate
  def User.count_by_affiliate
    sql = "select aff_long_name, count(*) from user_table, affiliate " +
      "where user_affiliate=aff_id " +
      "group by aff_long_name order by 2 desc"
    $store.raw_select(sql)
  end

  ######################################################################

  # Return a count of items that match a particular set of criteria

  def User.count_from_search(where, tables)
    tables = tables.reject {|t| t == UserTable}
    $store.count_complex(UserTable,
                         tables,
                         where)
  end

  ######################################################################
  # Return a set of rows for a download

  def User.download(col_names, where, table_names, &block)
    sql = "select #{col_names} from #{table_names}"
    sql << " where #{where}" unless where.empty?
    sql << " order by con_last_name, con_first_name " if table_names =~ /contact/
    $stderr.puts sql
    $store.raw_select(sql, &block)
  end


  #################################################################


  def User.count_for_region(reg_id)
    $store.count(UserTable, "user_region=?", reg_id)
  end

  #################################################################


  def User.reassign_region(old_reg_id, new_reg_id)
    $store.update_where(UserTable,
                        "user_region=?",
                        "user_region=?",
                        new_reg_id,
                        old_reg_id)
  end


  #################################################################

  attr_reader :new_user

  #################################################################

  def initialize(data_object = nil)
    @data_object = data_object || fresh_user
#    @data_object.user_level ||= NORMAL
    @user_over_13 = @new_user ? false : true
  end

  def fresh_user
    @new_user = true
    res = UserTable.new
    res.user_first_logged_in = Time.now
    res.user_last_logged_in = Time.now
    res
  end


  # Lazy read the contact information
  def contact
    @contact ||= get_contact(@data_object.user_contact)
  end

  # Return a new plaintext password
  def create_new_password
    pass = generate_password
    set_password(pass)
    pass
  end


  # Create a new password for this user, and send notification
  # to the user

  def send_new_password(template)

    pass = create_new_password
    set_password(pass)
    save


    mailer = Mailer.new

    user_name = @data_object.user_acc_name
    if user_name.nil? || user_name.empty?
      user_name = contact.con_email
    end

    values = { 
      "user_name" => user_name,
      "password"  => pass
    }

    mailer.send_from_template(contact.con_email,
                              "Your DION Registration Information",
                              values,
                              template)
  end

  # encrypt the given password make it ours
  def set_password(pass)
    self.user_password = User.crypt(pass)
  end


  # put this user's stuff into a hash

  def add_to_hash(hash)
    super
    contact.add_to_hash(hash)
    hash['user_over_13'] = @user_over_13 || !@new_user
    hash['last_logged_in'] = fmt_date_time(@data_object.user_last_logged_in)
    hash['first_logged_in'] = fmt_date_time(@data_object.user_first_logged_in)
#    aff_opts = Affiliate.options

    hash
  end

  # Return any validation errors from this user
  # or its contact. The contact validation is
  # somewhat stricter if we have no e-mail address,
  # or if we're shipping materials

  def error_list(strict=false)
    errors = []
    
    if @new_user && !@user_over_13
      errors << "Users must be 13 or older to register on this system"
      return errors
    end

    if @data_object.user_affiliate == Affiliate::NONE.to_s
      errors << "Please specify an affiliate"
    end

    errors.concat contact.error_list(strict || contact.con_email.empty?)
  end

  # Recover our state from form fields
  def from_hash(hash)
    @data_object.user_acc_name = hash['user_acc_name']
    @data_object.user_affiliate = hash['user_affiliate']
    @user_over_13 = hash['user_over_13']

    contact.from_hash(hash)
  end


  # log to the UserHistory table
  def log(notes)
    @uh_log ||= UserHistory.new
    @uh_log.log(self, notes)
  end

  # Save the user object back to the database
  # the database ID
  def save

    @data_object.user_acc_name.downcase! if @data_object.user_acc_name

#    unless @data_object.existing_record?
      tmp = User.with_name(@data_object.user_acc_name)
      if tmp && (!@data_object.existing_record? || tmp.user_id != @data_object.user_id)
        raise DionException.new("Sorry, but that nickname has been taken")
      end
      
#      tmp = User.with_email(contact.con_email)
#      if tmp && (!@data_object.existing_record? || tmp.user_id != @data_object.user_id)
#        raise DionException.new("A user with that e-mail address already exists" +
#                                  " #{tmp.user_id}, #{@data_object.user_id}")
#      end
#    end


    # This is tacky, but I can't see an easy way around it. If we fail inserting the
    # user record because of a duplicate nickname, then we'll have already written
    # out the contact record. The rollback will delete that out (or reset its field
    # values), but the in-store copy won't know that. So, we save away the contact
    # stuff and restore it in case of an exception

#    $store.transaction do

      begin

#        saved_contact = Marshal.dump(contact)

#        prev_con_id = @data_object.user_contact
        
        @data_object.user_contact = contact.save

        begin
          super
        rescue Exception => e
#          @contact = Marshal.load(saved_contact)
#          @data_object.user_contact = saved_contact
          raise
        end
        
      rescue DBI::ProgrammingError => e
        $stderr.puts e.message
        $stderr.puts e.backtrace

        case e.message
        when /duplicate key into unique index contact_con_email_key/,
             /duplicate key violates unique constraint "contact_con_email_key"/
          raise DionException.new("A user with that e-mail address already exists")
        when /duplicate key into unique index user_table_user_acc_name_key/
          raise DionException.new("Sorry, but that nickname has been taken")
        else
          raise
        end
      end

#    end
  end

  # Lazy load an affiliate
  def affiliate
    @affiliate || Affiliate.with_id(@data_object.user_affiliate)
  end

  #####################################################################
  #
  # Role stuff
  #

  def role_add(aff, reg, role_name, table_name=nil, target=nil)
    Role.add(@data_object.user_id, aff, reg, role_name, table_name, target)
  end

  def role_set(aff, reg, role_name, table_name=nil, target=nil)
    Role.set(@data_object.user_id, aff, reg, role_name, table_name, target)
  end

  # record the fact that this user is registered in an affiliate
  def register_affiliate_role
    Role.set_user_role(@data_object.user_id, 
                       user_affiliate, 
                       nil,
                       RoleNameTable::REGISTERED,
                       TargetTable::AFFILIATE,
                       user_affiliate)
  end


  def role_assoc_with_affiliate?(aff_id)
    Role.count_user_in_affiliate(@data_object.user_id, aff_id) > 0
  end

  #####################################################################
  #
  #   Affiliate stuff. A user has one primary and any number of
  #   secondary affiliates.

  # Is this user associated with the given affiliate?
  def associated_with_affiliate?(aff_id)
    (aff_id == @data_object.user_affiliate) ||
      role_assoc_with_affiliate?(aff_id)
  end

  private

  def get_contact(con_id)
    if con_id
      Contact.with_id(con_id)
    else
      Contact.new
    end
  end
  
  def User.crypt(string)
    string.crypt("  ")
  end

  def generate_password
    PassPhrase.instance.next
  end
end

