desc 'Manage customers, suppliers, offers, invoices and such'

long_desc <<EOS
Business-related commands deal with customers, suppliers, offers,
invoices (incoming and outgoing), taxes and such things.
EOS

command :business do |c|
  path = File.join(File.dirname(__FILE__), 'business')
  Dir.entries(path).sort.each do |entry|
    file = File.join(path, entry)
    if file.end_with?('.rb') and File.file?(file)
      c.instance_eval File.read(file), file, 1
    end
  end
end
