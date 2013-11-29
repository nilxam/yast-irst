# encoding: utf-8

module Yast
  class IrstClient < Client
    def main
      Yast.import "UI"

      #**
      # <h3>Configuration of IRST</h3>

      textdomain "irst"

      # The main ()
      Builtins.y2milestone("----------------------------------------")
      Builtins.y2milestone("Irst module started")

      Yast.import "Progress"
      Yast.import "Report"
      Yast.import "Popup"
      Yast.import "String"
      Yast.import "FileUtils"

      Yast.import "CommandLine"
      Yast.include self, "irst/wizards.rb"

      Yast.include self, "irst/uifunctions.rb"

	  # main ui function
	  @ret = IrstSequence()

	  Builtins.y2debug("ret=%1", @ret)

	  # Finish
	  Builtins.y2milestone("Irst module finished")
	  Builtins.y2milestone("----------------------------------------")

	  deep_copy(@ret) 

      # EOF
    end
  end
end

Yast::IrstClient.new.main
