NotifyMenu
==========

Simple Mac OS X menu bar alert notifications

You can add items to the notifications list using Applescript:

$ osascript -e 'tell application "NotifyMenu" to add alert "Some message"'

Items can have optional handlers, which are simple text tokens which are passed
to the handler (below):

$ osascript -e 'tell application "NotifyMenu" to add alert "Message" with handler "foo"'

And on clicking the alert in the menu, the following command will be
executed with the text of the alert as the first argument and the handler (if
available) as the second argument:

~/libexec/alert-handler
