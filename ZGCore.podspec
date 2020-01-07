Pod::Spec.new do |s|
  s.name     = 'ZGCore'
  s.version  = '1.0.0'
  s.license  = { :type => "MIT", :file => "FILE_LICENSE" }
  s.summary  = '基础框架核心模块'
  s.homepage = 'https://github.com/ZGComponent-based/ZGCore.git'
  #s.social_media_url = 'https://xx'
  s.authors  = { 'zhaogang' => '372398930@qq.com'}
  s.source   = { :git => 'https://github.com/ZGComponent-based/ZGCore.git', :tag => s.version}
  s.requires_arc = true

  s.dependency 'CryptoSwift','1.0.0'
  s.dependency 'SwiftKeychainWrapper','3.4.0'
  s.dependency 'CoreStore','5.0.6'
  s.frameworks = 'Foundation', 'UIKit', 'SystemConfiguration'

  s.swift_version = '5.0'
  s.ios.deployment_target = '9.0'

  s.subspec 'Extensions' do |ss|
    ss.source_files = 'ZGCore/Extensions/**/*.swift'
  end

  s.subspec 'Utils' do |ss|
    ss.source_files = 'ZGCore/Utils/**/*.swift'
  end
end
