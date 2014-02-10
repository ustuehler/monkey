# Replaced "stmttrnrs" with "stmtrs", because that's what GnuCash for
# Android generates when it exports multiple accounts.

require 'ofx'

class OFX::Parser::OFX102
  private

  def build_bank_account
    html.search("stmtrs").each_with_object([]) do |account, accounts|
      args = {
        :bank_id      => account.search("bankacctfrom > bankid").inner_text,
        :id           => account.search("bankacctfrom > acctid").inner_text,
        :type         => ACCOUNT_TYPES[account.search("bankacctfrom > accttype").inner_text.to_s.upcase],
        :transactions => build_transactions(account.search("banktranlist > stmttrn")),
        :balance      => build_balance(account),
        :currency     => account.search("curdef").inner_text
      }

      accounts << OFX::Account.new(args)
    end
  end
end
