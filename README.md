NotifyMenu
==========

Simple Mac OS X menu bar alert notifications

You can add items to the notifications list using Applescript:

$ osascript -e 'tell application "NotifyMenu" to add "Some message"'

And on clicking the alert in the menu, the following command will be
executed with the text of the alert as the only argument:

~/libexec/alert-handler
