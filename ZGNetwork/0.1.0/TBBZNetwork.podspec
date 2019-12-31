Pod::Spec.new do |s|
  s.name     = 'EFNetwork'
  s.version  = '0.1.0'
  s.license  = { :type => "MIT", :file => "FILE_LICENSE" }
  s.summary  = '基础框架核心模块'
  s.homepage = 'http://git.temp-inc.com/mobile_swift/tbbz-network'
  #s.social_media_url = 'https://xx'
  s.authors  = { 'yangenfeng' => 'yangenfeng@rd.temp.com' }
  s.source   = { :git => 'http://git.temp-inc.com/mobile_swift/tbbz-network.git', :tag => s.version}
  s.requires_arc = true

  s.dependency 'EFCore'
  s.dependency 'Alamofire'

  s.ios.deployment_target = '8.0'

  s.source_files = 'EFNetwork/**/*.swift'

end
