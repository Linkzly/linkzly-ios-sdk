Pod::Spec.new do |s|
  s.name             = 'LinkzlySDK'
  s.version          = '1.0.8'
  s.summary          = 'Linkzly iOS SDK for deep linking and attribution tracking'
  s.description      = <<-DESC
LinkzlySDK is a powerful iOS SDK for deep linking, attribution tracking, and analytics.
Features include Universal Links support, deferred deep linking, SKAdNetwork integration,
and comprehensive event tracking with privacy controls.
                       DESC

  s.homepage         = 'https://github.com/MarenTech/linkzly-ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Linkzly' => 'support@linkzly.com' }
  s.source           = { :git => 'https://github.com/MarenTech/linkzly-ios-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.14'
  s.swift_version = '5.0'

  # Use the pre-built XCFramework
  s.vendored_frameworks = 'Sources/Linkzly.xcframework'

  s.frameworks = 'Foundation', 'UIKit', 'StoreKit'
  s.ios.framework = 'UIKit'

  # No third-party dependencies
  # s.dependency 'SomeFramework'

end
