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
    user.enforce_account_standing_policy
  end
end

class User
  def enforce_account_standing_policy
    state.enforce_account_standing
  end

  private
  def state
    @state ||= if all_cards_invalid?
      UserWithInvalidCard.new(self)
    elsif have_coupon?
      UserWithCoupon.new(self)
    else
      UserWithValidSubscription.new(self)
    end
  end
end

class AccountStandingState
  def send_disable_notification
    # ...
  end

  def enforce_account_standing
    #success by default
  end
end

class UserWithInvalidCard < AccountStandingState
  def initialize(user)
    @user = user
  end

  def enforce_account_standing
    @user.disable!
    send_disable_notification
  end
end

#default implementations fine for these for now
class UserWithCoupon < AccountStandingState; end
class UserWithValidSubscription < AccountStandingState; end
