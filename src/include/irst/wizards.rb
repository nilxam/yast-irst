# encoding: utf-8

module Yast
  module IrstWizardsInclude
    def initialize_irst_wizards(include_target)
      Yast.import "UI"

      textdomain "irst"

      Yast.import "Sequencer"
      Yast.import "Wizard"
      Yast.import "Stage"

      Yast.include include_target, "irst/complex.rb"
      Yast.include include_target, "irst/dialogs.rb"
    end

    # Main workflow of the irst configuration
    # @return sequence result
    def MainSequence
      aliases = { "conf" => lambda { RunIrstDialogs() } }

      sequence = {
        "ws_start" => "conf",
        "conf"     => { :abort => :abort, :next => :next }
      }

      ret = Sequencer.Run(aliases, sequence)
      deep_copy(ret)
    end

    # Whole configuration of irst
    # @return sequence result
    def IrstSequence
      aliases = {
        "read"  => [lambda { ReadDialog() }, true],
        "main"  => lambda { MainSequence() },
        "write" => [lambda { WriteDialog() }, true]
      }

      sequence = {
        "ws_start" => "read",
        "read"     => { :abort => :abort, :next => "main" },
        "main"     => { :abort => :abort, :next => "write" },
        "write"    => { :abort => :abort, :next => :next }
      }

	  Wizard.CreateDialog
	  Wizard.SetTitleIcon("yast-irst")

      ret = Sequencer.Run(aliases, sequence)
      UI.CloseDialog
      deep_copy(ret)
    end



    # Whole configuration of irst but without reading and writing.
    # For use with autoinstallation.
    # @return sequence result
    def IrstAutoSequence
      Wizard.CreateDialog
      Wizard.SetContentsButtons(
        "",
        VBox(),
        "",
        Label.BackButton,
        Label.NextButton
      )
      if Stage.initial
        Wizard.SetTitleIcon("irst") # no .desktop file in inst-sys
      else
        Wizard.SetDesktopIcon("irst")
      end
      ret = MainSequence()
      UI.CloseDialog
      deep_copy(ret)
    end
  end
end
