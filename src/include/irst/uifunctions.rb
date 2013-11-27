# encoding: utf-8

module Yast
  module IrstUifunctionsInclude
	def initialize_irst_uifunctions(include_target)
	  textdomain "irst"

	  Yast.import "Popup"
	  Yast.import "Irst"
	end

	# Function initializes option "Enable/Disable irst"
	def InitEnableDisalbeIrst(key)
	  case Irst.wakeup_events_param
	  when 0
		UI.ChangeWidget(Id("EnableDisalbeIrst"), :Value, "disable_irst")
	  when 1
		UI.ChangeWidget(Id("EnableDisalbeIrst"), :Value, "enable_irst_timer_exp")
	  when 2
		UI.ChangeWidget(Id("EnableDisalbeIrst"), :Value, "enable_irst_battery_cri")
	  else
		UI.ChangeWidget(Id("EnableDisalbeIrst"), :Value, "enable_irst_any")
	  end

	  nil
	end

	# Function stores option "Enable/Disable IRST"
	#
	def StoreEnableDisalbeIrst(key, event)
	  event = deep_copy(event)
	  radiobut = Convert.to_string(
		UI.QueryWidget(Id("EnableDisalbeIrst"), :Value)
	  )
	  if radiobut == "disable_irst"
		Irst.wakeup_events_param = 0
	  elsif
		Irst.wakeup_events_param = 1
	  elsif
		Irst.wakeup_events_param = 2
	  else
		Irst.wakeup_events_param = 3
	  end

	  nil
	end

	# Function initializes option
	# "WakeupTimer"
	def InitWakeupTimer(key)
	  if Ops.greater_than(Irst.wakeup_time_param, 0)
		Builtins.y2debug("time_param=%1", Irst.wakeup_time_param)
		UI.ChangeWidget(
		  Id("wakeup_timer"),
		  :Value,
		  Irst.wakeup_time_param
		)
	  else
		UI.ChangeWidget(Id("wakeup_timer"), :Value, 0)
	  end

	  nil
	end

	#  Store function for option
	# "WakeupTimer"

	def StoreWakeupTimer(key, event)
	  event = deep_copy(event)
	  Irst.wakeup_time_param = Builtins.tostring(
		UI.QueryWidget(Id("wakeup_timer"), :Value)
	  )

	  nil
	end
  end
end
