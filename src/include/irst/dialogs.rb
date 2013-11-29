# encoding: utf-8

module Yast
  module IrstDialogsInclude
    def initialize_irst_dialogs(include_target)
      textdomain "irst"

      Yast.import "CWM"
      Yast.import "Label"
      Yast.import "Wizard"
      Yast.import "Irst"
      Yast.import "DialogTree"
      Yast.import "CWMTab"

      Yast.include include_target, "irst/helps.rb"
      Yast.include include_target, "irst/uifunctions.rb"

      @wid_handling = {
        "DisBackButton"          => {
          "widget"        => :custom,
          "custom_widget" => Empty(),
          "init"          => fun_ref(method(:DisBackButton), "void (string)"),
          "help"          => " "
        },
        #---------============ Start-up screen=============------------
        "EnableDisableIrst"     => {
          #TRANSLATORS: RadioButtonGroup Label
          "label"       => _(
            "Enable/Disable IRST"
          ),
          "widget"      => :radio_buttons,
		  "items"       => [
			["disable_irst", _("&Disable IRST")],
			["enable_irst_timer_exp", _("E&nable IRST, enter hibernation when the wakeup timer expires")],
			["enable_irst_battery_cri", _("Enable IRST, enter hibernation when the &battery reaches a critical level")],
			["enable_irst_any", _("Enable IRST, enter hibernation when &either the wakeup timer expires or the battery reaches a critical level")]
		  ],
		  "orientation" => :horizontal,
          "init"        => fun_ref(
            method(:InitEnableDisableIrst),
            "void (string)"
          ),
          "store"       => fun_ref(
            method(:StoreEnableDisableIrst),
            "void (string, map)"
          ),
          "help"        => HelpIrst("EventsRadioBut")
        },
        "EnableDisableIrstWOBattery"     => {
          #TRANSLATORS: RadioButtonGroup Label
          "label"       => _(
            "Enable/Disable IRST"
          ),
          "widget"      => :radio_buttons,
		  "items"       => [
			["disable_irst", _("&Disable IRST")],
			["enable_irst_timer_exp", _("E&nable IRST, enter hibernation when the wakeup timer expires")]
		  ],
		  "orientation" => :horizontal,
          "init"        => fun_ref(
            method(:InitEnableDisableIrst),
            "void (string)"
          ),
          "store"       => fun_ref(
            method(:StoreEnableDisableIrst),
            "void (string, map)"
          ),
          "help"        => HelpIrst("EventsRadioBut")
        },
        "WakeupTimer"            => {
          "widget"            => :custom,
          "custom_widget"     => HSquash(
            VBox(
              Left(
                IntField(
                  Id("wakeup_timer"),
                  Opt(:notify),
                  _("&Timer [Minutes]"),
                  0,
                  1440,
                  0
                )
              )
            )
          ),
          "init"              => fun_ref(
            method(:InitWakeupTimer),
            "void (string)"
          ),
          "store"             => fun_ref(
            method(:StoreWakeupTimer),
            "void (string, map)"
          ),
          "help"              => HelpIrst("WakeupTimer")
        }
      }

	  if Irst.have_battery
		@tabs = {
		  "start_up"           => {
			"contents"        => VBox(
			  "EnableDisableIrst",
			  #`VStretch ()
			  VSpacing(1),
			  Frame(
				_("Wakeup Timer"),
				HBox(HSpacing(1), VBox(Left("WakeupTimer")))
			  ),
			  VStretch()
			),
			"caption"         => _("IRST Settings"),
			"tree_item_label" => _("Start-Up"),
			"widget_names"    => [
			  "DisBackButton",
			  "EnableDisableIrst",
			  "WakeupTimer"
			]
		  }
		}
	  else
		@tabs = {
		  "start_up"           => {
			"contents"        => VBox(
			  "EnableDisableIrstWOBattery",
			  #`VStretch ()
			  VSpacing(1),
			  Frame(
				_("Wakeup Timer"),
				HBox(HSpacing(1), VBox(Left("WakeupTimer")))
			  ),
			  VStretch()
			),
			"caption"         => _("IRST Settings"),
			"tree_item_label" => _("Start-Up"),
			"widget_names"    => [
			  "DisBackButton",
			  "EnableDisableIrstWOBattery",
			  "WakeupTimer"
			]
		  }
		}
	  end
	end

	def DisBackButton(key)
	  Wizard.SetTitleIcon("yast-irst")
	  UI.ChangeWidget(Id(:back), :Enabled, false)

	  nil
	end

	def RunIrstDialogs
	  sim_dialogs = [
		"start_up"
	  ]

      DialogTree.ShowAndRun(
        #"functions"	: " ",
        {
          #return CWMTab::CreateWidget($[
          "ids_order"      => sim_dialogs,
          "initial_screen" => "start_up",
          "screens"        => @tabs,
          "widget_descr"   => @wid_handling,
          "back_button"    => "",
          "abort_button"   => Label.CancelButton,
          "next_button"    => Label.OKButton
        }
      )
    end
  end
end
