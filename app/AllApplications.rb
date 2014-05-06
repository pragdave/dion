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

class AffiliateProducts < Application
  require 'bo/CombinedProducts'
  class AppData; end
end

class AssignToRegion < Application
  require 'bo/Affiliate'
  class AppData; end
end

class CreditCardResponse < Application; class AppData; end; end

class CreditCards < Application; class AppData; end; end

class Cycles < Application; 
  require 'bo/FeeCycle'
  class AppData; end
end

class DailyPlanet < Application; class AppData; end; end
class DLChallenges < Application; class AppData; end; end
class Invoicing < Application; class AppData; end; end
class ListPurchaseOrders < Application; class AppData; end; end
class Login < Application; class AppData; end; end
class MaintainAffiliates < Application; class AppData; end; end
class MaintainChallenges < Application; class AppData; end; end
class MaintainProducts < Application; class AppData; end; end
class MaintainRegions < Application; class AppData; end; end
class MaintainRoles < Application; class AppData; end; end
class MaintainSales < Application; class AppData; end; end
class NameGetter < Application; class AppData; end; end
class OrderStatus < Application; class AppData; end; end
class OrderTeampak < Application; class AppData; end; end
class PaymentStatus < Application; class AppData; end; end
class Portal < Application; class AppData; end; end
class ReceiveCheckForPO < Application; class AppData; end; end
class ReceivePayment < Application; class AppData; end; end
class Register < Application; class AppData; end; end
class RequestChange < Application; class AppData; end; end
class Shipping < Application; class AppData; end; end
class TeamPaks < Application; class AppData; end; end

class Teams < Application
  require 'bo/UsersWithRole'
  class AppData; end;
end

class UserStuff < Application; class AppData; end; end
