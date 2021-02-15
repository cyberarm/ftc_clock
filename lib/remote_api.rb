class RemoteAPI
  URI = "druby://localhost:8787"

  def initialize(view)
    @view = view
  end

  def start_clock(mode)
    @view.clock_controller = case mode
    when :full_match
      ClockController.new(0, ClockController::FULL_MATCH)
    when :autonomous
      ClockController.new(0, ClockController::AUTONOMOUS)
    when :full_teleop
      ClockController.new(33.0, ClockController::FULL_TELEOP)
    when :teleop_only
      ClockController.new(41.0, ClockController::TELEOP)
    when :endgame_only
      ClockController.new(131.0, ClockController::TELEOP_ENDGAME)
    else
      nil
    end

    @view.clock.controller = @view.clock_controller
  end

  def abort_clock
    @view.clock_controller = nil
    @view.clock.controller = nil
  end

  def set_title(string)
    @view.clock.title.text = string.to_s
    @view.clock.title.x = @view.window.width / 2 - @view.clock.title.width / 2
  end

  def get_title(string)
    @view.clock.title
  end

  def shutdown!
    DRb.stop_service

    exit
  end
end