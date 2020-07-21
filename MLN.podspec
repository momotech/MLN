#
# Be sure to run `pod lib lint MLNCore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'MLN'
    s.version          = '1.0.0.1.fix7'
    s.summary          = 'A lib of Momo Lua Native.'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = <<-DESC
    A lib of Momo Lua Native Core.
    DESC
    
    s.homepage         = 'https://mln.immomo.com'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = 'MoMo'
    s.source           = { :git => 'https://github.com/momotech/MLN.git', :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
    s.ios.deployment_target = '8.0'
    s.libraries = 'z'
    s.requires_arc = true
    
    s.subspec 'LuaLib' do |lua|
        lua.name = 'LuaLib'
        lua.source_files = 'MLN-iOS/MLN/Classes/LuaLib/**/*.{h,m,c}'
        lua.public_header_files = 'MLN-iOS/MLN/Classes/LuaLib/**/*.h'
    end
    
    s.subspec 'Core' do |c|
        c.name = 'Core'
        c.framework = 'Foundation', 'UIKit'
        c.source_files = 'MLN-iOS/MLN/Classes/Core/**/*.{h,m,c}'
        c.public_header_files = 'MLN-iOS/MLN/Classes/Core/**/*.h'
        c.dependency  'MLN/LuaLib'
    end
    
    s.subspec 'Kit' do |k|
        k.name = 'Kit'
        k.framework = 'Foundation', 'UIKit', 'CoreGraphics', 'AVFoundation'
        k.source_files = 'MLN-iOS/MLN/Classes/Kit/**/*.{h,m,c}'
        k.public_header_files = 'MLN-iOS/MLN/Classes/Kit/**/*.h'
        k.dependency  'MLN/Core'
        #k.dependency  'KVOController'
    end
    
end
