NotifyMenu
==========

##### Simple Mac OS X menu bar alert notifications

You can add items to the notifications list using Applescript:

$ osascript -e 'tell application "NotifyMenu" to add alert "Some message"'

Items can have optional handlers, which are simple text tokens which are passed
to the handler (below):

$ osascript -e 'tell application "NotifyMenu" to add alert "Message" with handler "foo"'

And on clicking the alert in the menu, the following command will be
executed with the text of the alert as the first argument and the handler (if
available) as the second argument:

~/libexec/alert-handler

##### Credits:

This is my first attempt at Objective C programming.  The code based on a bunch
of resources online, including:

- [Xcode 4.1 Tutorial - Create a menu bar application (YouTube)](https://www.youtube.com/watch?v=HRPMFNDcfLY)
- [OS X Menu Bar App (GitHub)](https://github.com/chivalry/os-x-menu-bar-app)
- [How do I add Applescript support to my Cocoa application? (StackOverflow)](http://stackoverflow.com/a/10773994)

And Apple's Developer Documentation:

- [Implementing a Scriptable Application](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ScriptableCocoaApplications/SApps_implement/SAppsImplement.html)
