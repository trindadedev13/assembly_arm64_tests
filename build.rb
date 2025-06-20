require 'fileutils'
require 'timeout'

# Set required environment variables
ENV["DISPLAY"] = ":0"

def run(cmd)
  system(cmd) or abort ">> Command failed: #{cmd}"
end

def build
  output_dir = "#{ENV["HOME"]}/temp/asmwindow"
  use_termux = true
  FileUtils.mkdir_p(output_dir)

  FileUtils.mkdir_p("build")

  # Compile
  run("gcc -c -fPIC src/main.s -o build/main.o")
  run("ld build/main.o -o build/main -L#{ENV["PREFIX"]}/lib -lX11")
  run("gcc build/main.o -o #{output_dir}/main -nostdlib -lX11")

  # Run
  run("chmod +x #{output_dir}/main")

  if use_termux
    unless system("command -v termux-x11 > /dev/null")
      abort ">> Missing dependency: termux-x11. Install with: pkg install termux-x11"
    end

    puts ">> Starting X11 with DISPLAY=#{ENV["DISPLAY"]}"
    x11_pid = spawn(
      {
        "DISPLAY" => ENV["DISPLAY"],
        "XKB_CONFIG_ROOT" => ENV["XKB_CONFIG_ROOT"],
        "XKB_DEFAULT_LAYOUT" => "br",
        "XKB_DEFAULT_MODEL" => "pc105",
        "XKB_DEFAULT_RULES" => "evdev",
      },
      "termux-x11", ENV["DISPLAY"]
    )

    Signal.trap("INT") do
      cleanup_x11(x11_pid)
    end

    # Wait for X11 socket to become available
    begin
      Timeout.timeout(10) do
        until File.exist?("#{ENV["PREFIX"]}/tmp/.X11-unix/X0")
          sleep 0.5
        end
      end
      puts ">> X11 is ready"
    rescue Timeout::Error
      cleanup_x11(x11_pid)
      abort ">> X11 did not initialize: socket timeout"
    end

    run("#{output_dir}/main")

    cleanup_x11(x11_pid)
  else
    run("#{output_dir}/main")
  end
end

def cleanup_x11(pid)
  puts "Shutting down X11 (PID #{pid})..."
  Process.kill("TERM", pid)
  exit
end

build