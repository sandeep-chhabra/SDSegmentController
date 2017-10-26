#
# Be sure to run `pod lib lint SDSegmentController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SDSegmentController'
  s.version          = '1.0.2'
  s.summary          = 'SDSegmentController is a wrapper for segment control which gives features like segment control used in google products'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
SDSegmentController uses Page Controller and Custom SegmentControl. It will help you in tapping the segment and corresponding Page will be opened. Also Swiping left and right will automatically scroll respective segment.
DESC

  s.homepage         = 'https://github.com/sandeep-chhabra/SDSegmentController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'sandeep-chhabra' => 'sandeepchhabra.90@live.com' }
  s.source           = { :git => 'https://github.com/sandeep-chhabra/SDSegmentController.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'SDSegmentController/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SDSegmentController' => ['SDSegmentController/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
