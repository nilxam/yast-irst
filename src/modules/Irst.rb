# encoding: utf-8

require "yast"

module Yast
  class IrstClass < Module
    def main
      textdomain "irst"

      Yast.import "Progress"
      Yast.import "Summary"
      Yast.import "Message"
      Yast.import "Label"
      Yast.import "Popup"
      Yast.import "FileUtils"

	  # Data was modified?
	  @modified = false

      # Write only, used during autoinstallation.
      # Don't run services and SuSEconfig, it's all done at one place.
      @write_only = false

	  # The value of wakeup_events
	  # 1: Wake to enter hibernation when the wakeup timer expires
	  # 2: Wake to enter hibernation when the battery reaches a critical level
	  # 3: Wake to enter hibernation when either the wakeup timer expires or 
	  #    the battery reaches a critical level
	  # type: integer
	  @wakeup_events_param = 0

	  # The value of wakeup_time
	  # The length of time the system will remain asleep before waking up to 
	  # enter hibernation. The value is in minutes.
	  # min: 0 (immediately)
	  # max: 1440
	  # type: integer
	  @wakeup_time_param = 0

	  # IRST enabled?
	  # type: boolean
	  @irst_enable = false

	  # Have IRST ACPI devicey?
	  # type: boolean
	  @have_irst_device = false

	  # Loaded IRST kernel module?
	  # type: boolean
	  @loaded_irst_km = false

	  # Have IRST driver?
	  # type: boolean
	  @have_irst_driver = false

	  # Have battery?
	  # type: boolean
	  @have_battery = true

	  # Abort function
      # return boolean return true if abort
      @AbortFunction = nil
    end

    # Abort function
    # @return [Boolean] return true if abort
    def Abort
      return @AbortFunction.call == true if @AbortFunction != nil
      false
    end

	# Data was modified?
	# @return true if modified
	def GetModified
	  Builtins.y2debug("modified=%1", @modified)
	  @modified
	end  


	# Set data was modified
	def SetModified
	  @modified = true 
	  Builtins.y2debug("modified=%1", @modified)

	  nil  
	end

	#  @return [Boolean] successfull
	def ReadIrstAcpiDevice
	  if FileUtils.Exists("/sys/bus/acpi/devices/INT3392:00")
		@have_irst_device = true
		Builtins.y2debug("have_irst_device=%1", @have_irst_device)
	  else
		return false
	  end

	  true
	end

	#  @return [Boolean] successfull
	def ReadIrstKernelModule
	  if FileUtils.Exists("/sys/bus/acpi/drivers/intel_rapid_start")
		@loaded_irst_km = true
		Builtins.y2debug("loaded_irst_km=%1", @loaded_irst_km)
	  else
		return false
	  end

	  true 
	end

	#  @return [Boolean] successfull
	def ReadIrstKernelDriver
	  wakeup_events_path = "/sys/bus/acpi/drivers/intel_rapid_start/INT3392:00/wakeup_events"
	  wakeup_time_path = "/sys/bus/acpi/drivers/intel_rapid_start/INT3392:00/wakeup_time"
	  if FileUtils.Exists(wakeup_events_path) && FileUtils.Exists(wakeup_time_path)
		@have_irst_driver = true
		Builtins.y2debug("have_irst_driver=%1", @have_irst_driver)
	  else
		return false
	  end

	  true 
	end

	#  @return [Boolean] successfull
	def ReadIrstParams
	  driver_path = "/sys/bus/acpi/drivers/intel_rapid_start/INT3392:00/"
	  @wakeup_events_param = SCR.Read(path(".target.string"), driver_path + "wakeup_events").chomp.to_i
	  @wakeup_time_param = SCR.Read(path(".target.string"), driver_path + "wakeup_time").chomp.to_i

	  true 
	end

	# Read all irst params
	# @return true on success
	def Read
	  # Irst read dialog caption
	  caption = _("Initializing IRST Configuration")
	  steps = 5

      Progress.New(
        caption,
        " ",
        steps,
        [
          # Progress stage 1/5
          _("Detecting IRST ACPI device..."),
          # Progress stage 3/5
          _("Detecting IRST Kernel driver..."),
          # Progress stage 4/5
          _("Reading battery status..."),
          # Progress stage 5/5
          _("Reading the parameters from IRST driver...")
        ],
        [
          # Progress step 1/5
          _("Detecting IRST ACPI device..."),
          # Progress step 2/5
          _("Detecting IRST Kernel module..."),
          # Progress finished 3/5
          _("Detecting IRST Kernel driver..."),
          # Progress finished 4/5
          _("Reading the parameters from IRST driver..."),
          # Progress finished 5/5
          _("Finished")
        ],
        ""
      )

      # read database
      return false if Abort()
      Progress.NextStage
      # Error message
      if !ReadIrstAcpiDevice()
        Report.Error(_("Cannot read IRST ACPI device /sys/bus/acpi/devices/INT3392:00"))
      end

      # read another database
      return false if Abort()
      Progress.NextStep
      # Error message
      if !ReadIrstKernelModule()
        Report.Error(_("Cannot found kernel module intel_rst."))
      end

      # read another database
      return false if Abort()
      Progress.NextStep
      # Error message
      if !ReadIrstKernelDriver()
        Report.Error(_("IRST kernel driver doesn't work."))
      end

      # read another database
      return false if Abort()
      Progress.NextStep
      # Error message
      if !ReadIrstParams()
        Report.Error(_("Cannot read IRST parameters."))
      end

      return false if Abort()
      # Progress finished
      Progress.NextStage

      return false if Abort()
      @modified = false
      true
    end

    # Write all irst params
    # @return true on success
    def Write
      # Irst read dialog caption
      caption = _("Saving IRST Configuration")

      #number of stages
      steps = 1

      # We do not set help text here, because it was set outside
      Progress.New(
        caption,
        " ",
        steps,
        [
          # Progress stage
          _("Write the settings")
        ],
        [
          # Progress step
          _("Writing the settings..."),
          # Progress finished
          _("Finished")
        ],
        ""
      )

      # write settings
      return false if Abort()
      Progress.NextStage
      # Error message
      if !WriteIrstParameter()
        Report.Error(_("Update the value to parameters fault."))
      end

      return false if Abort()
      # Progress finished
      Progress.NextStage

      return false if Abort()
      true
    end

    # Create a textual summary and a list of unconfigured cards
    # @return summary of the current configuration
	def Summary
	  result = []
	  if @wakeup_events_param != 0
		@irst_enable = true
	  end
	  result = Builtins.add(
		result,
		Builtins.sformat(
		  _("Intel Rapid Start Technology status: %1"),
		  @irst_enable ? _("enabled") : _("disabled")
		)
	  )
	  if @wakeup_events_param == 1
		result = Builtins.add(
		  result,
		  Builtins.sformat(
			_("Wake-Up Event: %1"),
			_("the wakeup timer expires.")
		  )
		)
	  elsif @wakeup_events_param == 2
		result = Builtins.add(
		  result,
		  Builtins.sformat(
			_("Wake-Up Event: %1"),
			_("the battery reaches a critical level.")
		  )
		)
	  elsif @wakeup_events_param == 3
		result = Builtins.add(
		  result,
		  Builtins.sformat(
			_("Wake-Up Event: %1"),
			_("the wakeup timer expires or the battery reaches a critical level.")
		  )
		)
	  end
	  result = Builtins.add(
		result,
		Builtins.sformat(
		  _("Timer: %1 minutes"),
		  Builtins.tostring(@wakeup_time_param)
		)
	  )
	  deep_copy(result)
	end

	publish :variable => :modified, :type => "boolean"
	publish :variable => :write_only, :type => "boolean"
	publish :variable => :wakeup_events_param, :type => "integer"
	publish :variable => :wakeup_time_param, :type => "integer"
	publish :variable => :irst_enable, :type => "boolean"
	publish :variable => :have_battery, :type => "boolean"
	publish :variable => :AbortFunction, :type => "boolean ()"
	publish :function => :GetModified, :type => "boolean ()"
	publish :function => :SetModified, :type => "void ()"
    publish :function => :Abort, :type => "boolean ()"
    publish :function => :Read, :type => "boolean ()"
    publish :function => :Write, :type => "boolean ()"
    publish :function => :Summary, :type => "list <string> ()"
  end

  Irst = IrstClass.new
  Irst.main
end
