module Monkey::Banking
  # HBCI online-banking account
  class Account::HBCI < Account
    # Return +true+ since this is an account that can be used with
    # online-banking.
    #
    # (@see Account#online?)
    def online?
      true
    end

    # Transfer some +amount+ to another account.
    #
    # (@see Account#transfer)
    def transfer(raccount, amount, purpose = [])
    end
  end
end
