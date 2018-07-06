#
# Be sure to run `pod lib lint SABlurImageView.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SABlurImageView"
  s.version          = "5.0.0"
  s.summary          = "You can use blur effect and it's animation easily to call only two methods."

  s.homepage         = "https://github.com/marty-suzuki/SABlurImageView"

  s.license          = 'MIT'
  s.author           = { "Taiki Suzuki" => "s1180183@gmail.com" }
  s.source           = { :git => "https://github.com/marty-suzuki/SABlurImageView.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/marty_suzuki'

  s.ios.frameworks   = 'UIKit', 'QuartzCore', 'Accelerate'
  s.tvos.frameworks  = 'UIKit', 'QuartzCore', 'Accelerate'
  s.macos.frameworks = 'AppKit', 'QuartzCore', 'Accelerate'

  s.ios.deployment_target   = '8.0'
  s.tvos.deployment_target  = '9.0'
  s.macos.deployment_target = '10.9'

  s.source_files = 'Sources/**/*.{swift}'
end
