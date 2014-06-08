NotifyMenu
==========

##### Simple Mac OS X menu bar alert notifications

![Sample](https://dl.dropboxusercontent.com/s/45bx6zlv57zmggp/Screenshot%202014-06-08%2014.07.24.png)

You can add items to the notifications list using Applescript:

$ osascript -e 'tell application "NotifyMenu" to add alert "Some message"'

Items can have optional handlers, which are simple text tokens which are passed
to the handler (below):

$ osascript -e 'tell application "NotifyMenu" to add alert "Message" with handler "foo"'

If an executable file named "notifymenu-alert-handler" is found in $HOME/libexec,
on clicking the alert in the menu, the text of the alert will be passed to it as
the first argument and the handler (if available) as the second:

~/libexec/notifymenu-alert-handler "message" "handler"

##### Credits:

This is my first attempt at Objective C programming.  The code based on a bunch
of resources online, including:

- [Xcode 4.1 Tutorial - Create a menu bar application (YouTube)](https://www.youtube.com/watch?v=HRPMFNDcfLY)
- [OS X Menu Bar App (GitHub)](https://github.com/chivalry/os-x-menu-bar-app)
- [How do I add Applescript support to my Cocoa application? (StackOverflow)](http://stackoverflow.com/a/10773994)

And Apple's Developer Documentation:

- [Implementing a Scriptable Application](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ScriptableCocoaApplications/SApps_implement/SAppsImplement.html)

Icons From [OpenClipArt.org](https://openclipart.org/detail/3743/warning-notification-by-zeimusu)
