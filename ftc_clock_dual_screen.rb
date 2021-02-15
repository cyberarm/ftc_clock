require "drb/drb"

require_relative "lib/remote_control"

pid = Process.spawn(
  RbConfig.ruby,
  "#{File.expand_path(__dir__)}/ftc_clock.rb",
  "FIRST TECH CHALLENGE",
  "--remote-control"
)

RemoteControlWindow.new(width: 1000, height: 600, resizable: true).show
Process.wait(pid)