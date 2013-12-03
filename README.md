Chivy
=====

iOS web browser control which looks and behaves like modern Safari and is highly customizable


Work in progress
================

### Main features and their state:

* all the features are customizable and can be turned off. Main customization point is ```webBrowserController.cAttributes``` property. Feel free to access it from storyboard runtime attributes section;
* hiding top navigation bar on scrolling down the webView and showing it on scrolling up
* the transition to web browser controller can be:
    - **modal**, which creates the navigation controller and presents it by the controller you provide or rootViewController. There are much static helper methods in ```CHWebBrowserController``` to deal with it;
    - **push**, which exposes necessery properties to customize back button;
    - **storyboard segue**, to use it simply create the controller of class ```CHWebBrowserController_iPad``` or ```CHWebBrowserController_iPhone``` in your storyboard and remove its view in order to initiate it from imported xib;
* web browser controller handles basic HTTP authentication, providing user to enter login and password. Credits goes to TKAURLProtocol by Kiril Antonov. I've just patched it a bit to work with iOS 7;
* 'make page readable' action is a simple trigger of [Readability](http://www.readability.com/) bookmarklet (provided in .js), it features the user to experience the Readability service which makes (usually) the page easy to read on mobile device;
* the appearance can be customized using Interface Builder. I like it, neither do you?


Installation
============

### via CocoaPods (not yet released)

for now you will need [my fork of SuProgress](https://github.com/DZamataev/SuProgress) project, cuz the original not yet accepted the necessery pull requests

and the project itself, which is not yet released to CocoaPods, so the bleeding edge version is the only available option

```
pod 'SuProgress', :git => 'https://github.com/DZamataev/SuProgress.git', :branch => 'master'
pod 'Chivy', :git => 'https://github.com/DZamataev/Chivy.git', :branch => 'master'
```

### no Cocoapods
copy everything from folder named ```Core```
and deal with bundles as you like, here i dont care (excuse me for forcing you to use CocoaPods)

---------------

[![follow button](http://dzamataev.github.io/images/twitter_follow.png)](https://twitter.com/DZamataev)

[![endorse](https://api.coderwall.com/dzamataev/endorsecount.png)](https://coderwall.com/dzamataev)
