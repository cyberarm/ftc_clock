class View < CyberarmEngine::GuiState
  def setup
    window.show_cursor = true

    @clock = Clock.new
    @clock_controller = nil
    @clock.controller = nil

    stack do
      button "Start Match" do
        @clock_controller = ClockController.new(0, ClockController::FULL_MATCH)
        @clock.controller = @clock_controller
      end

      button "Start Autonomous Only" do
        @clock_controller = ClockController.new(0, ClockController::AUTONOMOUS)
        @clock.controller = @clock_controller
      end

      button "Start TeleOp Only" do
        @clock_controller = ClockController.new(41.0, ClockController::TELEOP)
        @clock.controller = @clock_controller
      end

      button "Start TeleOp Endgame Only" do
        @clock_controller = ClockController.new(131.0, ClockController::TELEOP_ENDGAME)
        @clock.controller = @clock_controller
      end

      button "Abort" do
        @clock_controller = nil
        @clock.controller = nil
      end
    end
  end

  def draw
    super

    @clock.draw
  end

  def update
    super

    @clock.update
    @clock_controller.update if @clock_controller
  end
end