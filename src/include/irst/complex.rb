# encoding: utf-8

module Yast
  module IrstComplexInclude
    def initialize_irst_complex(include_target)
      Yast.import "UI"

      textdomain "irst"

      Yast.import "Label"
      Yast.import "Popup"
      Yast.import "Wizard"
      Yast.import "Irst"

      Yast.include include_target, "irst/helps.rb"
    end

    # Return a modification status
    # @return true if data was modified
    def Modified
      Irst.GetModified
    end

    def ReallyAbort
      !Irst.GetModified || Popup.ReallyAbort(true)
    end

    def PollAbort
      UI.PollInput == :abort
    end

    # Read settings dialog
    # @return `abort if aborted and `next otherwise
    def ReadDialog
      ret = Irst.Read
      ret ? :next : :abort
    end

    # Write settings dialog
    # @return `abort if aborted and `next otherwise
    def WriteDialog
      Wizard.RestoreHelp(Ops.get_string(@HELPS, "write", ""))
      ret = Irst.Write
      ret ? :next : :abort
    end
  end
end
