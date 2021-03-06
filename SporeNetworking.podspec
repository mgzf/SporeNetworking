#
# Be sure to run `pod lib lint SporeNetworking.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SporeNetworking'
  s.version          = '0.2.3'
  s.summary          = 'POP Networking'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
SporeNetworing is POP-Networking-framework.
                       DESC

  s.homepage         = 'http://git.mogo.com/NeXTPod/SporeNetworking'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'loohawe@gamil.com' => 'luhao@mogoroom.com' }
  s.source           = { :git => 'git@git.mogo.com:NeXTPod/SporeNetworking.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/loohawe'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Sources/**/*'
  
  # s.resource_bundles = {
  #   'SporeNetworking' => ['SporeNetworking/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency "Result", "~> 3.0"
end
