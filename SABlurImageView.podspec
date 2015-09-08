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
  s.version          = "1.2.0"
  s.summary          = "You can use blur effect and it's animation easily to call only two methods."

  s.homepage         = "https://github.com/szk-atmosphere/SABlurImageView"

  s.license          = 'MIT'
  s.author           = { "Taiki Suzuki" => "s1180183@gmail.com" }
  s.source           = { :git => "https://github.com/szk-atmosphere/SABlurImageView.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/SzkAtmosphere'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'SABlurImageView/*.{swift}'
  # s.resource_bundles = {
  #   'SABlurImageView' => ['Pod/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'QuartzCore', 'Accelerate'
  # s.dependency 'AFNetworking', '~> 2.3'
end
