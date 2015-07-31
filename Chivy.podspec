Pod::Spec.new do |s|
  s.name             = "Chivy"
  s.version          = "0.5.0"
  s.summary          = "iOS web browser control which looks and behaves like modern Safari and is highly customizable"
  s.homepage         = "https://github.com/DZamataev/Chivy"
  s.screenshots     = "https://raw.githubusercontent.com/DZamataev/Chivy/master/Chivy-0.2.0-iPhone-screenshot.png"
  s.license          = 'MIT'
  s.author           = { "Denis Zamataev" => "denis.zamataev@gmail.com" }
  s.source           = { :git => "https://github.com/DZamataev/Chivy.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/dzamataev'

  s.platform     = :ios, '7.0'
  s.requires_arc = true
    
  s.default_subspec = 'Core'
  
  s.subspec 'Core' do |c|
    c.requires_arc = true
    c.source_files = 'Pod/Classes/*'
    c.resources = 'Pod/Assets/*'
  
  	c.dependency 'Chivy/Core-no-arc'
    
    c.dependency 'NJKWebViewProgress'
    c.dependency 'AutoScrollLabel'
  	c.dependency 'DKNavbarBackButton'
  	c.dependency 'ARChromeActivity'
  	c.dependency 'ARSafariActivity'
  end
  
  s.subspec 'Core-no-arc' do |cna|
    cna.requires_arc = false
    cna.source_files = 'Pod/Classes-no-arc/*'
  end
  
end
