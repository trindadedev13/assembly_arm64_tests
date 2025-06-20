
if ARGV.length < 1
  puts "Usage: ruby elf2text <elf>"
  exit 1
end

filename = ARGV[0]

if File.exist?(filename)
  puts File.binread(filename)
end