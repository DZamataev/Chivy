Chivy
=====

iOS web browser control which looks and behaves like modern Safari and is highly customizable


Work in progress
================

Main features and their state:

* all the features are customizable and can be turned off. Main customization point is webBrowserController.cAttributes property.
* hiding top navigation bar on scrolling down the webView and showing it on scrolling up
* the transition to web browser controller can be:
    - modal, which creates the navigation controller and presents it to the controller. There are much static helper methods in ```CHWebBrowserController``` to deal with it
    - push, which exposes necessery properties to customize back button
    - storyboard segue, to use it simply create the controller of class ```CHWebBrowserController_iPad``` or ```CHWebBrowserController_iPhone``` in your storyboard and delete its view in order to initiate it from existing xib.
* web browser controller handles basic HTTP authentication, providing user to enter login and password. Credits goes to TKAURLProtocol by Kiril Antonov.
* 'make page readable' action is a simple trigger of [Readability](http://www.readability.com/) bookmarklet (provided in .js), it features the user to experience the Readability service which makes (usually) the page easy to read on mobile device.
* the appearance can be customized using Interface Builder. I like it, neither do you?


