
if ARGV.length < 1
  puts "Usage: ruby hex2text.rb <hex>"
  exit 1
end

hex = ARGV[0]

if hex.start_with?("@")
  filename = hex[1..]
  if File.exist?(filename)
    hex = File.read(filename)
  end
end

text = [hex].pack("H*")
puts text.bytes