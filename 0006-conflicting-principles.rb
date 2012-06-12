#At the end of this screencast, Gary leaves us with this code:
#
class SessionsController
  def create
    user = log_user_in
    AccountStandingPolicy.new(user).enforce!
  end
end

class AccountStandingPolicy
  def initialize(user)
    @user = user
  end

  def enforce!
    # XXX: Tell Don't Ask
    if @user.all_cards_invalid?
      @user.disable!
      send_disable_notification!
    end
  end

  def send_disable_notification!
    # ...
  end
end

class User
  def disable!
    # ...
  end
end

#This code violates Tell Don't Ask, as Gary's comments say, but he can't find a way to fix this without violating another principle. Here's an attempt:
#
class SessionsController
  def create
    user = log_user_in
    user.account_standing_policy.enforce!
  end
end

class User
  def account_standing_policy
    AccountStandingPolicy.create(self, :cards_invalid => all_cards_invalid?,
                                       :has_coupon  => has_coupon?)
  end
end

class AccountStandingPolicy
  def create(user, opts)
    if opts[cards_invalid]
      InvalidCardPolicy.new(user)
    elsif opts[has_coupon]
      WithCouponPolicy.new(user)
    else
      ValidSubscriptionPolicy.new(user)
    end
  end

  def send_disable_notification!
    # ...
  end

  def enforce!
    #success by default
  end
end

class InvalidCardPolicy < AccountStandingPolicy
  def initialize(user)
    @user = user
  end

  def enforce!
    @user.disable!
  end
end

#default implementations fine for these for now
class WithCouponPolicy < AccountStandingPolicy; end
class ValidSubscriptionPolicy < AccountStandingPolicy; end
