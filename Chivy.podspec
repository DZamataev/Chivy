Pod::Spec.new do |s|
  s.name         = "Chivy"
  s.version      = "0.1.0"
  s.summary      = "iOS web browser control which looks and behaves like modern Safari and is highly customizable"
  s.homepage     = "https://github.com/DZamataev/Chivy.git"
  s.license      = { :type => 'MIT', :file => 'LICENSE'}
  s.author       = { "Denis Zamataev" => "denis.zamataev@gmail.com" }
  
  s.source       = {
      :git => "https://github.com/DZamataev/Chivy.git",
      :tag => s.version.to_s
    }
	
  s.ios.deployment_target = '7.0'
  
  non_arc_files = 'Core/Source/TKAURLProtocol.m'

  s.requires_arc = true
  
  s.default_subspec = 'Core'

  s.subspec 'Core' do |c|
    c.source_files = 'Core/Source/*'
	c.exclude_files = non_arc_files
    c.resources = 'Core/Resources/*'
    c.dependency 'SuProgress'
    c.dependency 'AutoScrollLabel'
  end
  
  s.subspec 'Core-no-arc' do |cna|
    cna.requires_arc = false
    cna.source_files = non_arc_files
  end

  s.subspec 'Demo' do |d|
    d.source_files = 'Demo/Source/*'
    d.resources = 'Demo/Resources/*'
    d.preserve_paths = "Chivy.xcodeproj", "Podfile"
    d.dependency 'Chivy/Core'
  end

end
