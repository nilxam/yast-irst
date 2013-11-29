# encoding: utf-8

module Yast
  module IrstUifunctionsInclude
	def initialize_irst_uifunctions(include_target)
	  textdomain "irst"

	  Yast.import "Popup"
	  Yast.import "Irst"
	end

	# Function initializes option "Enable/Disable irst"
	def InitEnableDisableIrst(key)
	  if Irst.have_battery
		id_tag = "EnableDisableIrst"
	  else
		id_tag = "EnableDisableIrstWOBattery"
	  end

	  case Irst.wakeup_events_param
	  when 0
		UI.ChangeWidget(Id(id_tag), :Value, "disable_irst")
	  when 1
		UI.ChangeWidget(Id(id_tag), :Value, "enable_irst_timer_exp")
	  when 2
		UI.ChangeWidget(Id(id_tag), :Value, "enable_irst_battery_cri")
	  else
		UI.ChangeWidget(Id(id_tag), :Value, "enable_irst_any")
	  end

	  nil
	end

	# Function stores option "Enable/Disable IRST"
	#
	def StoreEnableDisableIrst(key, event)
	  event = deep_copy(event)
	  if Irst.have_battery
		id_tag = "EnableDisableIrst"
	  else
		id_tag = "EnableDisableIrstWOBattery"
	  end

	  radiobut = Convert.convert(
		UI.QueryWidget(Id(id_tag), :Value),
		:from => "any",
		:to => "string"
	  )
	  if radiobut == "disable_irst"
		Irst.wakeup_events_param = 0
	  elsif radiobut == "enable_irst_timer_exp"
		Irst.wakeup_events_param = 1
	  elsif radiobut == "enable_irst_battery_cri"
		Irst.wakeup_events_param = 2
	  elsif radiobut == "enable_irst_any"
		Irst.wakeup_events_param = 3
	  end

	  nil
	end

	# Function initializes option
	# "WakeupTimer"
	def InitWakeupTimer(key)
	  if Ops.greater_than(Irst.wakeup_time_param, 0)
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
	  Irst.wakeup_time_param = Convert.convert(
		UI.QueryWidget(Id("wakeup_timer"), :Value),
		:from => "any",
		:to => "integer"
	  )

	  nil
	end
  end
end
