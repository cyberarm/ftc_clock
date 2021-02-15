require "drb/drb"

require_relative "lib/remote_control"

pid = Process.spawn(
  RbConfig.ruby,
  "#{File.expand_path(__dir__)}/ftc_clock.rb",
  "FIRST TECH CHALLENGE",
  "--dual-screen-mode"
)

sleep 5

RemoteControlWindow.new.show
Process.wait(pid)