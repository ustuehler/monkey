desc 'Business management commands'

long_desc <<EOS
Run business-related commands.  Business commands deal with customers,
suppliers, invoices (incoming and outgoing), taxes and such things.
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
