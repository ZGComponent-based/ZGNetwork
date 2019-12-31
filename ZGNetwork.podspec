Pod::Spec.new do |s|
  s.name     = 'ZGNetwork'
  s.version  = '1.0.0'
  s.license  = { :type => "MIT", :file => "FILE_LICENSE" }
  s.summary  = '基础框架核心模块'
  s.homepage = 'https://github.com/ZGComponent-based/ZGNetwork.git'
  #s.social_media_url = 'https://xx'
  s.authors  = { 'zhaogang' => '372398930@qq.com' }
  s.source   = { :git => 'https://github.com/ZGComponent-based/ZGNetwork.git', :tag => s.version}
  s.requires_arc = true

  s.dependency 'ZGCore'
  s.dependency 'Alamofire'
  s.dependency 'SwiftyJSON'
  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'

  s.source_files = 'ZGNetwork/**/*.swift'

end
