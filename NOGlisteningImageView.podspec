#
# Be sure to run `pod lib lint NOGlisteningImageView.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "NOGlisteningImageView"
  s.version          = "0.1.0"
  s.summary          = "A drop-in replacement for UIImageView. Repeatedly plays a simple highlight animation, similar to a highlight on a coin when a bright light moves quickly alongside it."
  s.description      = <<-DESC
Originally developed to be used in storyboards or nibs when it is needed to draw user attention to certain graphical elements. All public properties can be configured by setting in the User Defined Runtime Attributes section in Xcode's Identity Inspector.

Animations start playing automatically when this view is added to a UIWindow, and stops when it is removed form one.
                       DESC
  s.homepage         = "https://github.com/memega/NOGlisteningImageView"
  s.license          = 'MIT'
  s.author           = { "Yuriy Panfyorov" => "tohellwithmemega@gmail.com" }
  s.source           = { :git => "https://github.com/memega/NOGlisteningImageView.git", :tag => s.version.to_s }

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'NOGlisteningImageView' => ['Pod/Assets/*.png']
  }

  s.frameworks = 'QuartzCore'
end
