Personal Home/Office Automation Monkey
--------------------------------------

I'm slowly teaching my monkey to do all the chores that I don't like.  Every
now and then I teach it a new trick, but for now, here's what it can do...

**Accounting**

- reads and manipulates human-readable [ledger](http://ledger-cli.org) files
- imports bank statements in CSV format into my accounting ledger

**Banking**

- does online-banking via HBCI using [aqbanking-cli](http://www2.aquamaniac.de/sites/aqbanking/cli.php)
- checks account balances
- issues transfers

**Small-business management**

- keeps track of my customers and suppliers
- generates time-sheets for contract work
- generates invoices ready to send

**E-mail processing**

- accounts for business expenses extracted from received invoices
- stores time-recording reports for later time-sheet and invoice printing

Note: The published code does not do absolutely everything that is mentioned
above, some things are still implemented as crude Rake scripts, using Monkey
only as a Ruby library.

Usage
-----

Monkey's primary interface is a self-documenting command-line application, but
it can as well be used as a Ruby library.  I personally use Monkey from
[pry](http://pryrepl.org/) whenever I want to do something that isn't supported
by the command-line interface.

Here's how to get started:

```text
bundle install
bundle exec bin/monkey
```
