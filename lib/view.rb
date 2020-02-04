class View < CyberarmEngine::GuiState
  def setup
    @clock = Clock.new
    @clock_controller = ClockController.new(ClockController::FULL_MATCH)
    @clock.controller = @clock_controller

    stack do
      button "Start Match" do
        @clock_controller = ClockController.new(ClockController::FULL_MATCH)
        @clock.controller = @clock_controller
      end

      button "Start Autonomous Only" do
        @clock_controller = ClockController.new
        @clock.controller = @clock_controller
      end

      button "Start TeleOp Only" do
        @clock_controller = ClockController.new
        @clock.controller = @clock_controller
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
  end
end