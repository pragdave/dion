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

require "app/AffiliateProducts"
require "app/CreditCards"
require "app/Cycles"
require "app/DailyPlanet"
require "app/DLChallenges"
require "app/ListPurchaseOrders"
require 'app/Application'
require 'app/AssignToRegion'
require 'app/Download'
require 'app/GeneralOrders'
require 'app/Invoicing'
require 'app/Lists'
require 'app/MaintainAffiliates'
require 'app/MaintainAffiliateDates'
require 'app/MaintainChallenges'
require 'app/MaintainProducts'
require 'app/MaintainRegions'
require 'app/MaintainRoles_ADs'
require 'app/MaintainRoles_RDs'
require 'app/MaintainRoles_ICMs'
require 'app/MaintainRoles_HQ'
require 'app/MaintainRoles_HQO'
require 'app/MaintainSales'
require 'app/Orders'
require 'app/OrderStatus'
require 'app/OrderTeampak'
require 'app/Payments'
require 'app/PaymentReports'
require 'app/PaymentStatus'
require 'app/PortalTemplates'
require 'app/ProductList'
require 'app/ReceiveCheckForPO'
require 'app/ReceivePayment'
require 'app/Register'
require 'app/status/Status'
require 'app/status/AffiliateSummary'
require 'app/status/ProductSummary'
require 'app/TeamPaks'
require 'app/UpdateTeampak'
require 'app/UserStuff'
require "app/Shipping"
require 'bo/ChangeRequest'
require 'bo/RoleList'
require 'bo/Region'
require 'bo/Order'
require 'bo/TeamList'

class Portal < Application
  app_info(:name            => :Portal,
           :login_required  => true,
           :default_handler => :display_menu,
           :default_app     => true)


  class AppData
  end

  def app_data_type
    AppData
  end


  ######################################################################
  class MENU_BASE
    attr_reader :role_id

    def sm(label, klass, name=nil, *args)
      if klass
        { "url" => @context.url(klass, name, *args), "text" => label }
      else
        { "text" => label }
      end
    end

    def initialize(portal, context, role, session)
      @portal = portal
      @context = context
      @role_id = role.role_id
      @session = session
    end

    def popup_url
      @context.url(@portal.type, :popup_big_menu, self.type, @role_id)
    end

    def u(*args)
      @context.url(*args)
    end

    def teampak_count(n, extra)
      case n
      when 0 then "no #{extra}s"
      when 1 then "one #{extra}"
      else "#{n} #{extra}s"
      end
    end

  end

  ######################################################################

  class STANDARD_MENU < MENU_BASE

    def initialize(portal, context, role, session)
      super
      @affiliate = Affiliate.with_id(role.role_affiliate) || Affiliate.new
      @challenge_count = ChallengeDesc.count
      @has_active_memberships = Membership.has_active(session.user)
    end

    def small_menu
      menu = 
      [
        sm("Update my details", Login, :handle_menu), 
#        sm("Debug roles", Portal, :debug_roles),
      ]

      if @has_active_memberships
        if @challenge_count.zero?
          menu << sm("Download challenges#{Template::OPEN_TAG}br#{Template::CLOSE_TAG}" +
                       "(not yet available)", nil, nil)
          
        else
          menu << sm("Download challenges", DLChallenges, :display_dl_copyright)
        end
      end

      unless @affiliate.aff_is_sa
        if @affiliate.registration_open?
          menu << sm("Create new Teampak", Register)
#          unless @renews.empty
#            menu << sm("Renew existing TeamPak", Register, :list_renewals)
#          end
        end

#        menu << sm("Register for DI Later#{Template::OPEN_TAG}br#{Template::CLOSE_TAG}" +
#                   "(not yet available)", nil, nil)


### Removed by LM request...
#        if @affiliate.team_registration_open?
#          menu << sm("Register a Team", Teams, :general_change, @affiliate.aff_id)
#        end
      end

#Removed FK request      menu << sm("Other products", GeneralOrders, :order_for_user,
#                 @session.user.user_id)

      menu
    end

    def big_menu_values

      values = {
        "aff_set_up"     => @affiliate.is_set_up?,
        "aff_is_sa"      => @affiliate.aff_is_sa,
        "aff_short_name" => @affiliate.aff_short_name,
        "name"           => @portal.user_name,
#        "change_teams"   => u(Teams, :general_change, @affiliate.aff_id),
        "reg_url"        => u(Register),
        "pd_url"         => u(Login, :handle_menu),
        "order_url"      => u(GeneralOrders, :order_for_user, @session.user.user_id),
      }

      if @has_active_memberships
        unless @challenge_count.zero?
          values["dl_url"] =  u(DLChallenges, :display_dl_copyright)
        end
      else
        values["explain_challenges"] = true
      end

      Portal.add_reg_open_info(@affiliate, values)
      values
    end

    def big_menu_template
      STD_MENU_TEMPLATE
    end

    def small_title
      "User Menu"
    end
  end

  ######################################################################

  class RD_MENU < MENU_BASE
    def initialize(portal, context, role, session)
      super
      @region    = Region.with_id(role.role_target)
      @affiliate = Affiliate.with_id(role.role_affiliate)
    end

    def small_menu
      res = [
        sm("Update_news", DailyPlanet, :editors_desk,  @affiliate.aff_id, 
           @region.reg_id),
        sm("Find user", UserStuff, :search_for_user, @affiliate.aff_id),
        sm("Status",    AffiliateSummary, :affiliate_detail, @affiliate.aff_id),
        sm("Download",  Download, :start_selection,  @affiliate.aff_id),
        sm("Reports",   Lists,    :start_selection,  @affiliate.aff_id),
        sm("Find user", UserStuff, :search_for_user, @affiliate.aff_id),
      ]
      if @affiliate.aff_has_regions && @affiliate.aff_rds_can_assign
        res << sm("Assign to Region", AssignToRegion, :handle_display, @affiliate.aff_id)
        res << sm("Reassign to Region", AssignToRegion, :assign_search, aff_id)
      end

      res << {
        "url" => "doc/userguide/RD%20DION%20Manual.pdf", 
        "text" => "User Guide" 
      }
      res
    end

    def big_menu_values
      values = {
        "name"      => @portal.user_name,
        "reg_name"        => @region.reg_name,
        "aff_short_name"  => @affiliate.aff_short_name,
        "aff_short_name"  => @affiliate.aff_short_name,
        "update_news"     => u(DailyPlanet,
                               :editors_desk,
                               @affiliate.aff_id,
                               @region.reg_id),
      }

      if @affiliate.aff_has_regions && @affiliate.aff_rds_can_assign
        values["ass_to_reg_url"]  = u(AssignToRegion, :handle_display, @affiliate.aff_id)
        values["reass_to_reg_url"]  = u(AssignToRegion, :assign_search, @affiliate.aff_id)
      end

      values["download"]      = u(Download, :start_selection, @affiliate.aff_id)

      values["lists"]          = u(Lists, :start_selection, @affiliate.aff_id)

      values['user_search']    = u(UserStuff, :search_for_user, @affiliate.aff_id)

      values['change_teams']   = u(Teams, :general_change, @affiliate.aff_id)
      
      values['teampak_search'] = u(TeamPaks, :search_form,
                                       @affiliate.aff_id)

      values['affiliate_summary']  = u(AffiliateSummary, :affiliate_detail,
                                       @affiliate.aff_id)
      @affiliate.add_to_hash(values)

      if @affiliate.aff_has_regions
        unassigned = @affiliate.cities_of_paks_not_in_regions
        unless unassigned.empty?
          values['unassigned_cities'] = unassigned.join(", ")
        end
      end

      # summarize all counts
      counts = Membership.count(@affiliate)
      values['active_1'] = teampak_count(counts["1"][StateNameTable::Active], 
                                         "active OnePak")
      values['active_5'] = teampak_count(counts["5"][StateNameTable::Active],
                                         "active FivePak")
      values['waitpay']  = teampak_count(counts["1"][StateNameTable::WaitPayment] +
                                         counts["5"][StateNameTable::WaitPayment], "teampak")

     # See if we have teampaks with no teams
      empty_teampaks = Membership.count_active_with_no_teams(@affiliate.aff_id,
                                                             @region.reg_id)
      unless empty_teampaks.zero?
        if empty_teampaks == 1
          values['empty_teampaks'] = "one active TeamPak"
        else
          values['empty_teampaks'] = "#{empty_teampaks} active TeamPaks"
        end
        values['empty_teampaks_url'] = u(Lists, :do_specific_list,
                                         @affiliate.aff_id,
                                         @region.reg_id,
                                         Select::TEAMPAK,
                                         Select::TP_C_ACT_NO_TEAMS)
      end

      values
    end

    def big_menu_template
      RD_MENU_TEMPLATE
    end


    def small_title
      @region.reg_name
    end
  end

  ######################################################################

  class AD_MENU < MENU_BASE

    def initialize(portal, context, role, session)
      super
      @affiliate = Affiliate.with_id(role.role_affiliate)
    end

    def small_menu
      aff_id = @affiliate.aff_id
      res = [
        sm("Challenges", 
           MaintainChallenges, :ad_challenge_menu, aff_id),
        sm("Products", 
           AffiliateProducts, :maintain_products, aff_id),
        sm("Status", 
           AffiliateSummary,     :affiliate_detail,    aff_id),
        sm("Product status",
           ProductSummary,       :display,             aff_id),

        sm("Dates", MaintainAffiliateDates, :edit_dates, aff_id),
        sm("Download", Download, :start_selection,     aff_id),
        sm("Reports",    Lists,    :start_selection,     aff_id),
        sm("Update_news", DailyPlanet, :editors_desk,  aff_id),
        sm("Find user", UserStuff, :search_for_user,   aff_id),
      ]
      if @affiliate.aff_has_regions
        res << sm("Assign to Region", AssignToRegion, :handle_display, aff_id)
        res << sm("Reassign to Region", AssignToRegion, :assign_search, aff_id)
      end
      res
    end

    def big_menu_values
      values = {}

      aff_id = @affiliate.aff_id

      values["name"] = @portal.user_name

      values["download"]    = u(Download, :start_selection, aff_id)

      values["lists"]    = u(Lists, :start_selection, aff_id)

      values["update_news"] = u(DailyPlanet, :editors_desk, aff_id)
      
      values["aff_short_name"]  = @affiliate.aff_short_name
      
      values["maint_chall"]     = u(MaintainChallenges, 
                                    :ad_challenge_menu, 
                                    aff_id)
      
      values["maint_prod"]      = u(AffiliateProducts, 
                                    :maintain_products, 
                                    aff_id)
      
      values["maint_reg"]       = u(MaintainRegions, 
                                    :maintain_regions, 
                                    aff_id)
      
      
      values["maint_dates"]     = u(MaintainAffiliateDates, 
                                    :edit_dates, 
                                    aff_id)

      values['order_teampak']   = u(OrderTeampak, :order_third_party, aff_id)

      values['renew_teampak']   = u(OrderTeampak, :renew_third_party, aff_id)

      values['upgrade_teampak'] = u(OrderTeampak, :upgrade_third_party, aff_id)

      values['order_general']   = u(OrderGeneral, :order_third_party, aff_id)

      values['order_ad']        = u(GeneralOrders, :order_for_user, @session.user.user_id, true)
      
      values['change_teams']    = u(Teams, :general_change, aff_id)
      
      if @affiliate.aff_has_regions
        values["ass_to_reg_url"]  = u(AssignToRegion, :handle_display, aff_id)
        values["reass_to_reg_url"]  = u(AssignToRegion, :assign_search, aff_id)
      end

      values['user_search']       = u(UserStuff, :search_for_user, aff_id)
      values['teampak_search']    = u(TeamPaks, :search_form, aff_id)
      values['affiliate_summary'] = u(AffiliateSummary, :affiliate_detail, aff_id)
      values['product_summary']   = u(ProductSummary, :display, aff_id)

      unless @affiliate.is_set_up?
        values["not_set_up"]   = true
        values["setup_chall"]  = @affiliate.pending(Affiliate::TODO_CHALLENGES)
        values["setup_reg"]    = @affiliate.pending(Affiliate::TODO_REGIONS)
        values["setup_fees"]   = @affiliate.pending(Affiliate::TODO_FEES)
        values["setup_dates"]  = @affiliate.pending(Affiliate::TODO_DATES)
      end

      # summarize all counts
      counts = Membership.count(@affiliate)
      values['active_1'] = teampak_count(counts["1"][StateNameTable::Active], 
                                         "active OnePak")
      values['active_5'] = teampak_count(counts["5"][StateNameTable::Active],
                                         "active FivePak")
      values['waitpay']  = teampak_count(counts["1"][StateNameTable::WaitPayment] +
                                         counts["5"][StateNameTable::WaitPayment], "teampak")

      # See if we have teampaks with no teams
      empty_teampaks = Membership.count_active_with_no_teams(aff_id)
      
      unless empty_teampaks.zero?
        if empty_teampaks == 1
          values['empty_teampaks'] = "one active TeamPak"
        else
          values['empty_teampaks'] = "#{empty_teampaks} active TeamPaks"
        end
        values['empty_teampaks_url'] = u(Lists, :do_specific_list,
                                         aff_id,
                                         nil,
                                         Select::TEAMPAK,
                                         Select::TP_C_ACT_NO_TEAMS)
      end

      @affiliate.add_to_hash(values)

      if @affiliate.aff_has_regions
        unassigned = @affiliate.cities_of_paks_not_in_regions
        unless unassigned.empty?
          values['unassigned_cities'] = unassigned.join(", ")
        end
      end
      values
    end

    def big_menu_template
      AD_MENU_TEMPLATE
    end


    def small_title
      @affiliate.aff_short_name
    end
  end


  ######################################################################

  class HQ_MENU < MENU_BASE

    def initialize(portal, context, role, session)
      super
    end

    def small_menu
      nil
    end

    def big_menu_values
      values = {

        "name"            => @portal.user_name,

        'status_menu'     => u(Status, :status_menu),
        
        'find_order'      => u(OrderStatus, :find_order),
        'partially_paid'  => u(OrderStatus, :list_partially_paid),
        'unpaid_shipped'  => u(OrderStatus, :list_partially_paid_and_shipped),
        'maint_aff'       => u(MaintainAffiliates, :maintain_affiliates),
        'maint_chall'     => u(MaintainChallenges, :hq_challenge_menu),
        'maint_sales'     => u(MaintainSales,      :maintain_sales),
        'maint_prod'      => u(MaintainProducts,   :maintain_products),
        'prd_list'        => u(ProductList,        :list_products),
        'order_teampak'   => u(OrderTeampak,       :order_third_party),
        'renew_teampak'   => u(OrderTeampak,       :renew_third_party),
        'delete_teampak'  => u(TeamPaks,           :delete_teampak),
        'alter_teampak'   => u(TeamPaks,           :alter_teampak),
        'upgrade_teampak' => u(OrderTeampak,       :upgrade_third_party),
        

        'order_general'   => u(OrderGeneral,       :order_third_party),
        'adjust_order'    => u(Orders,             :adjust_order),
        'change_teams'    => u(Teams,              :general_change),
        'product_summary' => u(ProductSummary, :display),

        'user_search'     => u(UserStuff, :search_for_user),
        'user_create'     => u(UserStuff, :create_user),
        'become_user'     => u(Login,     :become_user),

        'role_ad'         => u(MaintainRoles_ADs,  :select_target),
        'role_icm'        => u(MaintainRoles_ICMs, :select_target),
        'role_hq'         => u(MaintainRoles_HQ,   :handle_one_role, 0),
        'role_hqo'        => u(MaintainRoles_HQO,  :handle_one_role, 0),

        "update_news"     => u(DailyPlanet, :editors_desk),
        "rec_pay_check"   => u(ReceivePayment, :handle_rec_check),
        "rec_pay_po"      => u(ReceivePayment, :handle_rec_po),
        "apply_po"        => u(ReceivePayment, :apply_existing_payment),
        "unpaid_pos"      => u(ListPurchaseOrders, :summary_of_unpaid),
        "check_for_po"    => u(ReceiveCheckForPO, :handle_rec_check_for_po),
        "find_payment"    => u(PaymentStatus,  :find_payment),
        "delete_payment"  => u(Payments,  :delete_payment),
        "edit_payment"    => u(Payments,  :edit_payment),

        "delete_order"    => u(Orders,  :delete_order),
        "edit_order"      => u(Orders,  :edit_order),

        "daily_money"     => u(PaymentReports, :daily_money_reports),

        "reprint_inv"     => u(Invoicing, :select_reprint),

        "cc_log"          => u(CreditCards, :cc_log),

        "cycle_summary"   => u(Cycles, :display_summary),
        "complete_cycle"  => u(Cycles, :complete_cycle),
        
        "shipping_summary" => u(Shipping, :shipping_summary),
        "shipping_report"  => u(Shipping, :shipping_report),

        "teampak_search"   => u(TeamPaks, :search_form),

        "download"         => u(Download, :start_selection),

        "lists"            => u(Lists, :start_selection),

        "print_test"       => u(Portal, :print_test),
      }

      cr_count = ChangeRequest.count

      if cr_count > 0
        values['cr_count'] = cr_count
        values['cr_url']   = u(RequestChange, :hq_menu)
      end

      values['link_to_jitterbug'] = true

      values
    end

    def big_menu_template
      HQ_MENU_TEMPLATE
    end


    def small_title
      "HQ Functions"
    end
  end

  ######################################################################

  class HQO_MENU < MENU_BASE

    def initialize(portal, context, role, session)
      super
    end

    def small_menu
      [
        sm('Status',    Status,    :status_menu),
        sm("Reportds",  Lists,     :start_selection),
        sm("Downloads", Download,  :start_selection),
        sm("Teampaks",  TeamPaks,  :search_form),
        sm('Users',     UserStuff, :search_for_user),
        sm('Aff. fees', Cycles,    :display_summary),
      ]
    end

    def big_menu_values
      {
        "name"            => @portal.user_name,
        'status_menu'     => u(Status, :status_menu),
        "lists"            => u(Lists, :start_selection),
        "download"         => u(Download, :start_selection),
        "teampak_search"   => u(TeamPaks, :search_form),
        'user_search'     => u(UserStuff, :search_for_user),
        "cycle_summary"   => u(Cycles, :display_summary),
      }
    end

    def big_menu_template
      HQO_MENU_TEMPLATE
    end


    def small_title
      "Observer Functions"
    end
  end

  ######################################################################
  # A fake menu to hold the status stuff

  class MenuStatus

    def initialize(html)
      @html = html
    end

    def role_id
      -1
    end

    def small_menu
      nil
    end

    def big_menu_values
      {}
    end

    def big_menu_template
      @html
    end


    def small_title
      "My TeamPak status"
    end
  end

  ######################################################################

  # Here are the handlers for particular roles

  MENU_FOR = {
    RoleNameTable::RD          => RD_MENU,
    RoleNameTable::AD          => AD_MENU,
    RoleNameTable::HQ          => HQ_MENU,
    RoleNameTable::HQ_OBSERVER => HQO_MENU,
  }


  def get_a_status(data, name, template_name, html)
    unless data.empty?
      values = { name => data }
      template = Template.new(template_name)
      template.write_html_on(html, values)
    end
  end

  def get_team_status(user)
    html = ""

    mems = Register.portal_data(user, @context)
    unless mems.empty?
      values = { 'mems' => mems }
      Portal.add_reg_open_info(user.affiliate, values)
      values['any_change_url'] = mems.find {|mem| mem['change_url']}
      values['any_suspended'] = mems.find {|mem| mem['suspended']}
      values['any_not_suspended'] = mems.find {|mem| mem['not_suspended']}
      template = Template.new(STATUS_TEAMPAKS)
      template.write_html_on(html, values)
    end

    teams = TeamList.for_user_id(user.user_id)
    tl = teams.portal_data(@context)
    get_a_status(tl, 'teams', STATUS_TEAMS, html)

    orders = Order.list_for_user(user.user_id)
    values = orders.map do |o|
      o.add_to_hash({ "order_url" => @context.url(OrderStatus, :display_from_id, o.order_id)})
    end

    get_a_status(values, 'orders', STATUS_ORDERS, html)

    html
  end


  ######################################################################

  ######################################################################
  ######################################################################

  # Display the user's menu

  def display_menu(big_role_id=nil)

    # When we get back here, we need to pop off any nested contexts

    @context.reset_stack

    rl = RoleList.new(@session.user)

    menus    = []
    statuses = []

    rl.each_role_name do |name|
      case name
      when RoleNameTable::RD
        @session.rd_session = true
      when RoleNameTable::AD
        @session.ad_session = true
      when RoleNameTable::HQ
        @session.hq_session = true
      end

      role_menu = MENU_FOR[name]
      if role_menu
        rl.each_relationship_for_name(name) do |role|
          menus << role_menu.new(self, @context, role, @session)
        end
      end
    end

#    if menus.empty?
    unless @session.hq_session
      role = Role.new
      role.role_affiliate = @session.user.user_affiliate
      role.role_id = -2
      menus << STANDARD_MENU.new(self, @context, role, @session) 
    end
#    end

    status = get_team_status(@session.user)

    if status.empty?
      menu_status = nil
    else
      menu_status = MenuStatus.new(status)
    end

    
    configure_page(big_role_id, menus, menu_status)
  end

  # The format page we display depends on the number of menus and
  # statii that the user should see
  #
  # 1xmenu,  0xstatus    =>     NEWS / BIG MENU
  #
  # 1xmenu with small handler, nxstatus  =>  [NEWS | SMALL MENU] / STATUS
  #
  # 1xmenu no small handler, nxstatus    =>  NEWS | BIG MENU + [show status]
  #
  # nxmenu, 0xstatus   => show first menu big, put rest in side menu
  #
  # nxmenu, nxstatus   => show status big, nxmenus in side menu
  #
  # Then to make it complex, we have the ability to force the
  # big menu to be a particular role id...

  def configure_page(big_role_id, menus, menu_status)
    small_menu = nil
    if menus.size == 1
      menu = menus[0]
      if !menu_status
        bottom_items =  menu 
      elsif menu.small_menu
        small_menu = menu
        bottom_items = menu_status
      else
        bottom_items =  menu  # + SHOW_STATUS_MENU
      end
    else
      small_menu = menus
      if !menu_status
        bottom_items = small_menu[0]
      else
        bottom_items = menu_status
        small_menu << menu_status
      end
    end

    if big_role_id
      bot = menus.find {|mi| mi.role_id == big_role_id }
      bottom_items =  bot  if bot
    end

    display_panes(small_menu, bottom_items)
  end


  def display_panes(small_menu, bottom_item)
    user = @session.user
    contact = user.contact
    name = contact.con_name

    values = {
      'name' => name,
      'logout' => ENV['SCRIPT_NAME'],
      'main_menu_url' => "http://www.destinationimagination.org",
      'main_menu' => "Destination Imagination"
    }

    add_news_headlines(values)

    if small_menu
      values['sidemenu'] = to_side_menu(small_menu)
    end
    
    bm = ""

    template = Template.new(bottom_item.big_menu_template)
    template.write_html_on(bm, bottom_item.big_menu_values)

    values['bigmenu'] = bm

    values['link_to_jitterbug'] = bottom_item.big_menu_values['link_to_jitterbug']

    values['is_hq_session'] = @session.hq_session

    standard_page("DION: #{name}'s Home Page",
                  values,
                  PORTAL_PAGE,
                  bm)
  end


  # convert a small menu to a side menu. If it's an
  # array, then our menu is an array of pointers to
  # each entry's big menu. If not, we just extract
  # it's small menu directly

  def to_side_menu(small_menu)
    if small_menu.kind_of? Array
      menu = small_menu.map do |mi|
        { 
          'url' => url(:popup_big_menu, mi.type, mi.role_id),
          'text' => mi.small_title,
        }
      end
    else
      menu = small_menu.small_menu
    end
    menu << 
      { "url" => ENV['SCRIPT_NAME'],     'text' => 'Logout' }
    menu
  end


  def user_name
    @session.user.contact.con_name
  end

  def popup_big_menu(klass, role_id)
    display_menu(role_id)
  end


  def add_news_headlines(values)
    unless  @session.news.empty? || @session.hq_session
      values['news'] = @session.news
      values['news'].each do |story|
        story['news_url'] = @context.url(DailyPlanet, 
                                         :display_news,
                                         story['news_id'])
      end
    end
    values['all_news_url']     = @context.url(DailyPlanet, :display_all_news)
    values['refresh_news_url'] = @context.url(DailyPlanet, :refresh_news)
  end

  def debug_roles
    res = RoleList.for_user(@session.user.user_id)

    puts "<html><table border=\"2\" cellpadding=\"3\">"
    puts "<tr><th>Role<th>With<th>Affiliate<th>Region</tr>"

    res.each do |role|
      print "<tr><td>#{role.name}</td><td>"
      
      if role.role_target_type
        print "#{role.target_name} '#{role.target_info}'"
      end
      print "</td><td>"
      print " #{role.affiliate.aff_short_name}" if role.role_affiliate
      print "</td><td>"
      
      print "#{role.region.reg_name}" if role.role_region
      print "</td>"
      puts "</tr>"
    end
    puts "</ul></html>"
  end

  def Portal.add_reg_open_info(affiliate, values)
    reg_open = false
    team_reg_open = false
    reg_open_msg = ""
    
    if affiliate.is_set_up?
      if affiliate.registration_open?
        reg_open = true
      else
        reg_open_msg = "You can purchase or renew TeamPaks between " +
          "#{affiliate.fmt_reg_start} and #{affiliate.fmt_reg_end}. "
      end
      if affiliate.team_registration_open?
        team_reg_open = true
      else
        reg_open_msg << "You can add teams to TeamPaks between " +
          "#{affiliate.fmt_team_reg_start} and #{affiliate.fmt_team_reg_end}. "
      end
      if affiliate.registration_passed? || affiliate.team_registration_passed?
        reg_open_msg +=
          "If you've missed the cutoff date, you could try contacting " +
          "your Affiliate Director for assistance."
      end
    else
      reg_open_msg = "Registration will open shortly. " +
        "Contact your Affiliate Director for details"
    end

    values["reg_open"]      = reg_open
    values["team_reg_open"] = team_reg_open
    values["explain_teams"] = reg_open || team_reg_open
    values["reg_open_msg"]  = reg_open_msg
  end

end
