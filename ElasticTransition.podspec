#
# Be sure to run `pod lib lint ElasticTransition.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ElasticTransition"
  s.version          = "1.0.0"
  s.summary          = "A UIKit custom modal transition that simulates an elastic drag. Written in Swift."

  s.description      = <<-DESC
                        Best for side menu and navigation transition.
                       DESC

  s.homepage         = "https://github.com/lkzhao/ElasticTransition"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Luke" => "lzhaoyilun@gmail.com" }
  s.source           = { :git => "https://github.com/lkzhao/ElasticTransition.git", :tag => s.version.to_s }
  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'ElasticTransition/*.swift'

  s.frameworks = ['UIKit', 'Foundation']
  # s.dependency 'AFNetworking', '~> 2.3'
end
