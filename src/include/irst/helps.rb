# encoding: utf-8

module Yast
  module IrstHelpsInclude
    def initialize_irst_helps(include_target)
      textdomain "irst"

      # All helps are here
      @HELPS = {
        #Wakeup Events - RadioButtons 1/1
        "EventsRadioBut"          => _(
          "<p><b>Wakeup Events</b><br>\n" +
		  "      Enable or disable Intel Rapid Start Technology.<br></p>\n"
        ),
        # Wakeup Timer [Minutes] - IntField 1/1
        "WakeupTimer"            => _(
          "<p><b>Wakeup Timer</b><br>\n" +
		  "      The length of time the system will remain asleep before waking up to enter hibernation.\n" +
		  "      This value is in minutes.<br></p>\n"
        ),
        # Read dialog help 1/2
        "read"                   => _(
          "<p><b><big>Initializing IRST Configuration</big></b><br>\nPlease wait...<br></p>\n"
        ) +
          # Read dialog help 2/2
          _(
            "<p><b><big>Aborting Initialization:</big></b><br>\nSafely abort the configuration utility by pressing <b>Abort</b> now.</p>\n"
          ),
        # Write dialog help 1/2
        "write"                  => _(
          "<p><b><big>Saving IRST Configuration</big></b><br>\nPlease wait...<br></p>\n"
        ) +
          # Write dialog help 2/2
          _(
            "<p><b><big>Aborting Saving:</big></b><br>\n" +
              "Abort the save procedure by pressing <b>Abort</b>.\n" +
              "An additional dialog informs whether it is safe to do so.\n" +
              "</p>\n"
          )
	  }
    end

    def HelpIrst(identification)
      Ops.get_string(
        @HELPS,
        identification,
        Builtins.sformat("Help for '%1' is missing!", identification)
      )
    end
  end
end
