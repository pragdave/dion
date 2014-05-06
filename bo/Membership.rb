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

require 'bo/MembershipHistory'

class Membership < BusinessObject

  OnePak  = "1"
  FivePak = "5"

#  attr_reader :creator
#  attr_reader :admin
  
  ######################################################################

  def Membership.with_full_passport(passport)
    mem = nil
    if passport =~ /^(\d\d\d)-?(\d+)$/
      mem = withPassport($1, $2)
    end
    mem
  end

  ######################################################################

  def Membership.withPassport(passport_prefix, passport)
    maybe_return($store.select_one(MembershipTable, 
                                   "mem_passport_prefix=? and mem_passport=?",
                                   passport_prefix, passport))
  end

  ######################################################################

  def Membership.with_id(mem_id)
    if mem_id
      maybe_return($store.select_one(MembershipTable, 
                                     "mem_id=?",
                                     mem_id))
    else
      nil
    end
  end

  ######################################################################

  def Membership.list_for_user(user)
    res = $store.select(MembershipTable,
                        "mem_creator=? or mem_admin=? order by mem_name",
                        user.user_id, user.user_id)
    res.map {|m| Membership.new(m)}
  end

  ######################################################################

  # return true iff the given user has at least one active membership
  def Membership.has_active(user)
    count = $store.count(MembershipTable,
                         "mem_state='#{StateNameTable::Active}' and " +
                           "(mem_creator=? or mem_admin=?)",
                         user.user_id, user.user_id)
    
    # Maybe this person is a teammanager
    if count.zero?
      sql = 
        "select count(*) from membership, team, role " +
        " where role_user=? " +
        "   and role_name=#{RoleNameTable::TEAM_MANAGER} " +
        "   and role_target=team_id " +
        "   and team_mem_id = mem_id " +
        "   and mem_state = '#{StateNameTable::Active}'"

      count = $store.basic_count(MembershipTable, sql, user.user_id)
    end

    count > 0
  end


  ######################################################################
  # return a count of registered, active, and fully paid
  # memberships by type

  def Membership.count(aff)
    sql = 
      "select mem_type, mem_state, count(mem_state) " +
      "  from membership " 

    if aff
      sql << " where mem_affiliate=#{aff.aff_id}" 
    end

    sql << " group by mem_type, mem_state"

    res = $store.raw_select(sql)
    counts = {
      "1" => {
        StateNameTable::Suspended   => 0,
        StateNameTable::WaitPayment => 0,
        StateNameTable::Active      => 0,
      },
      "5" => {
        StateNameTable::Suspended   => 0,
        StateNameTable::WaitPayment => 0,
        StateNameTable::Active      => 0,
      },
    }

    res.each do |mem_type, mem_state, count|
      counts[mem_type][mem_state.strip] = count rescue 0;
    end
    counts
  end


  ######################################################################

  def Membership.list_from_member_search(where, tables, limit=20)
    tables = tables.reject {|t| t == MembershipTable}
    res = $store.select_complex(MembershipTable,
                                tables,
                                where)
    res.map {|m| new(m) }
  end

  ######################################################################

  # Return a count of items that match a particular set of criteria

  def Membership.count_from_search(where, tables)
    tables = tables.reject {|t| t == MembershipTable}
    $store.count_complex(MembershipTable,
                         tables,
                         where)
  end

  ######################################################################
  # Return a set of rows for a download

  def Membership.download(col_names, where, table_names, &block)
    sql = "select #{col_names} from #{table_names}"
    sql << " where #{where}" unless where.empty?
    sql << " order by mem_name"
    $stderr.puts sql
    $store.raw_select(sql, &block)
  end

  ######################################################################

  # Return counts of numbers of memberships in each state, optionally
  # qualified by an affiliate id
  def Membership.count_passports(aff_id)
    sql = "select mem_state, count(*) from membership "
    params = []
    if aff_id
      sql << "where aff_id=? "
      params << aff_id
    end

    sql << "group by mem_state"

    counts = {}
    $store.raw_select(sql, *params) do |row|
      counts[row[0].strip] = row[1]
    end
    counts
  end


  #################################################################


  def Membership.count_for_region(reg_id)
    $store.count(MembershipTable, "mem_region=?", reg_id)
  end

  #################################################################


  def Membership.count_active_with_no_teams(aff_id, reg_id=nil)
    if reg_id
      ref = reg_id
      field = "mem_region"
    else
      ref = aff_id
      field = "mem_affiliate"
    end

    $store.count(MembershipTable,
                 "#{field}=? and mem_state='ACTIVE' and " +
                 "not exists (select 1 from team where team_mem_id=mem_id)", ref)
  end

  #################################################################


  def Membership.reassign_region(user, old_reg_id, new_reg_id)
    if new_reg_id
      reg = Region.with_id(new_reg_id)
      new_region = reg ? reg.reg_name : ""
    else
      reg = Region.with_id(old_reg_id)
      old_region = reg ? reg.reg_name : ""
    end
      

    res = $store.select(MembershipTable, "mem_region=?", old_reg_id) 

    res.each do |row|
      mem = new(row)
      mem.mem_region = new_reg_id
      mem.save
      if new_reg_id
        mem.log(user, "Reassigned to region '#{new_region}'")
      else
        mem.log(user, "Removed from region '#{old_region}'")
      end
    end
  end



  ######################################################################

  # Return a count of memberships grouped by affiliate
  def Membership.count_by_affiliate
    sql = "select aff_long_name, count(*) from affiliate, membership " +
      "where aff_id=mem_affiliate and mem_state<>'#{StateNameTable::Suspended}' " +
      "group by aff_long_name order by 2 desc"
    $store.raw_select(sql)
  end

  # Return a count of onepaks grouped by affiliate
  def Membership.onepaks_by_affiliate
    sql = "select aff_long_name, count(*) from affiliate, membership " +
      "where mem_type='#{OnePak}' " +
      "  and aff_id=mem_affiliate " +
      "  and mem_state<>'#{StateNameTable::Suspended}' " +
      "group by aff_long_name order by 2 desc"
    $store.raw_select(sql)
  end

  # Return a count of fivepaks grouped by affiliate
  def Membership.fivepaks_by_affiliate
    sql = "select aff_long_name, count(*) from affiliate, membership " +
      "where mem_type='#{FivePak}' " +
      "  and aff_id=mem_affiliate " +
      "  and mem_state<>'#{StateNameTable::Suspended}' " +
      "group by aff_long_name order by 2 desc"
    $store.raw_select(sql)
  end

  ######################################################################

  def initialize(data_object = nil)
    @data_object = data_object || MembershipTable.new
#    @creator = get_user(@data_object.mem_creator)
#    @admin   = get_user(@data_object.mem_admin)
  end

  def creator
    @creator ||= get_user(@data_object.mem_creator)
  end

  def admin
    @admin ||= get_user(@data_object.mem_admin)
  end

  def suspended?
    @data_object.mem_state == StateNameTable::Suspended
  end

  def full_passport
    if @data_object.mem_passport
      (@data_object.mem_passport_prefix.to_s + "-" + @data_object.mem_passport.to_s).strip
    else
      ""
    end
  end

  def add_to_hash(hash)
    super

    hash['full_passport'] = full_passport
    
    aff = Affiliate.with_id(@data_object.mem_affiliate)
    aff.add_to_hash(hash)

    if aff.aff_has_regions
      reg = Region.with_id(@data_object.mem_region)
      if reg
        reg.add_to_hash(hash)
      else
        hash['reg_name'] = 'Unassigned'
      end
    end

    hash['created_by'] =  [ creator.add_to_hash({})  ]
    hash['created_by'][0]['label'] = "Created by"

    hash['contact'] =  [ admin.add_to_hash({})  ]
    hash['contact'][0]['label'] = "Contact"

    hash
  end

  def log(user, notes)
    mh = MembershipHistory.new
    mh.log(@data_object.mem_id, user.user_id, notes)
  end


  # Log to the teampak's creator, contact, and any extra users
  def log_to_all(notes, *extra_user_ids)
    msg = "TeamPak #{full_passport}: #{notes}"
    users = (extra_user_ids << @data_object.mem_admin << @data_object.mem_creator).uniq
    users.each do |user_id|
      user = User.with_id(user_id)
      user.log(msg)
    end
  end

  def creator=(user)
    @creator = user
    @data_object.mem_creator = user.user_id
  end

  def admin=(user)
    @admin = user
    @data_object.mem_admin = user.user_id
  end

  def set_admin_from_email(email)
    return nil if !email.empty? && email == admin.contact.con_email

    admin_user = User.with_email(email)
    if admin_user
      self.admin = admin_user
    else
      self.admin = User.new
      admin.contact.con_email = email
      admin.user_affiliate = @data_object.mem_affiliate
    end
    nil
  end

  def admin_is_in_different_affiliate?
    !admin.associated_with_affiliate?(@data_object.mem_affiliate)
  end

  def admin_is_new?
    admin.user_id.nil?
  end

  def save
    @data_object.mem_last_activity = Time.now
    @data_object.mem_admin = admin.save

    admin_changed = @data_object.changed?(:mem_admin)
    region_changed = @data_object.changed?(:mem_region)

    mem_id = super

    if admin_changed
      admin.role_set(@data_object.mem_affiliate,
                      @data_object.mem_region,
                      RoleNameTable::TEAMPAK_CONTACT,
                      TargetTable::MEMBERSHIP,
                      mem_id)
    end

    if region_changed
      $stderr.puts "Changing region to #{@data_object.mem_region}"
      Role.change_membership_region(@data_object.mem_id, @data_object.mem_region)
    end
    
    return mem_id

  end


  # Handle state changes on payment

  def activate(session)
    @data_object.mem_is_active = true
    @data_object.mem_state     = StateNameTable::Active
    @data_object.mem_dt_activated = Time.now
    log(session.user, "TeamPak activated")
    save
  end

  # Reverse an activation
  def undo_activate(session)
    @data_object.mem_is_active = false
    @data_object.mem_state     = StateNameTable::WaitPayment
    @data_object.mem_dt_activated = nil
    log(session.user, "TeamPak deactivated")
    save
  end

  # hande the purchasing of an upgrade

  def upgrade(session)
    unless @data_object.mem_upgrade_pending
      raise "No upgrade pending for #{@data_object.mem_id} #{@data_object.mem_passport}"
    end
    @data_object.mem_upgrade_pending = false
    @data_object.mem_type = "5"
    msg = "Membership upgraded"
    log(session.user, msg)
    save
  end

  # and undo the purchase (leaving the upgrade pending)
  def undo_upgrade(session)
    unless @data_object.mem_type == "5"
      raise "Can't unupgrade #{@data_object.mem_id} #{@data_object.mem_passport}"
    end
    @data_object.mem_upgrade_pending = true
    @data_object.mem_type = "1"
    msg = "Membership upgrade removed"
    log(session.user, msg)
    save
  end

  # For use in Role.rb
  def target_name
    mem_name
  end

  def viewer_class
    Register
  end

  def viewer_method
    :handle_status
  end

  # Return the maximum number of teams this membership can have
  def max_teams
    if @data_object.mem_upgrade_pending
      5
    else
      @data_object.mem_type.to_i
    end
  end

  private


  def get_user(user_id)
    if user_id
      User.with_id(user_id)
    else
      User.new
    end
  end

end
