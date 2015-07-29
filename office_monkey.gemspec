require File.join(File.dirname(__FILE__), 'lib/monkey/version')

Gem::Specification.new do |s|
  s.name = "office_monkey"
  s.version = Monkey::VERSION
  s.summary = 'office automation monkey'
  s.description = 'My personal home and office automation monkey, taking some of the more tedious tasks of running a small business away.'
  s.authors = ['Uwe Stuehler']
  s.email = 'uwe@bsdx.de'
  s.files = `git ls-files lib`.split("\n")
  s.homepage = 'https://ustuehler.github.io/monkey'
  s.license = 'OpenBSD'

  # command-line interface libraries
  s.add_runtime_dependency 'gli'
  s.add_runtime_dependency 'highline'

  # database model
  s.add_runtime_dependency 'data_mapper'
  s.add_runtime_dependency 'dm-yaml-adapter'
  s.add_runtime_dependency 'dm-sqlite-adapter' # XXX: why, again?

  # accounting: importing OFX files
  s.add_runtime_dependency "banker-ofx", "~> 0.4.2"
  s.add_runtime_dependency "iconv" # required by banker-ofx

  # monkey-process_mail
  s.add_runtime_dependency 'mailman'
  s.add_runtime_dependency 'pry-rescue'
  s.add_runtime_dependency 'rake' # XXX: why was that?
  s.add_runtime_dependency 'rspec'
end
