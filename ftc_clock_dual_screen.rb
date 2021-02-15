require_relative "lib/remote_control"

pid = Process.spawn(
  RbConfig.ruby,
  "#{File.expand_path(__dir__)}/ftc_clock.rb",
  "--remote-control"
)

RemoteControlWindow.new(width: 1024, height: 600, resizable: true).show
Process.wait(pid)