
Pod::Spec.new do |s|
    
    s.name             = "ws"
    s.version          = "1.2.1"
    s.summary          = "Elegant JSON WebService for Swift ☁️"
    
    s.homepage         = "https://github.com/s4cha/ws"
    s.license          = { :type => "MIT", :file => "LICENSE" }
    s.author           = "S4cha"
    s.source           = { :git => "https://github.com/s4cha/ws.git", :tag => s.version.to_s }
    
    s.ios.deployment_target = "8.0"
    
    s.source_files = "ws/*.{h,m,swift}"

    s.frameworks = "Foundation"
    
    s.dependency "Arrow"
    s.dependency "thenPromise"
    s.dependency "Alamofire"

end
