#
# Be sure to run `pod lib lint ArgoUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'ArgoUI'
    s.version          = '0.4.3'
    s.summary          = 'A lib of Momo Lua UI.'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = <<-DESC
    A lib of Momo Lua UI.
    DESC
    
    s.homepage         = 'https://mln.immomo.com'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = 'MoMo'
    s.source           = { :git => 'https://github.com/momotech/MLN.git', :tag => 'ArgoUI/' + s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
    s.ios.deployment_target = '8.0'
    s.libraries = 'z','c++'
    s.requires_arc = true
    s.resource = 'MLN-iOS/MLN/Resource/ArgoUISystem.bundle'
    s.module_map = 'MLN-iOS/MLN/Classes/MUICore/module.modulemap'
    
    s.subspec 'Core' do |c|
        c.name = 'Core'
        c.framework = 'Foundation', 'UIKit'
        c.source_files = 'MLN-iOS/MLN/Classes/MUICore/**/*.{h,m,c}'
        c.public_header_files = 'MLN-iOS/MLN/Classes/MUICore/**/*.h'
        c.private_header_files = 'MLN-iOS/MLN/Classes/MUICore/argo_db/**/*.h'

        c.dependency  'MLN/LuaLib'
    end
    
    s.subspec 'Kit' do |k|
        k.name = 'Kit'
        k.framework = 'Foundation', 'UIKit', 'CoreGraphics', 'AVFoundation'
        k.source_files = 'MLN-iOS/MLN/Classes/MUIKit/**/*.{h,m,c,cpp,mm}'
#        k.exclude_files = 'MLN-iOS/MLN/Classes/MUIKit/Component/ObjectAnimation/Source/**/*.{h,c,cpp}'
        k.public_header_files = 'MLN-iOS/MLN/Classes/MUIKit/**/*.h'
        k.private_header_files = 'MLN-iOS/MLN/Classes/MUIKit/ArgoBinding/Listener/**/*.h',
                                 'MLN-iOS/MLN/Classes/MUIKit/ArgoBinding/Lua/**/*.h'
                                 
        k.dependency 'ArgoUI/Core'
        k.dependency 'ArgoAnimation'
        
#        k.subspec 'AnimationCPP' do |ani|
#          ani.name = 'AnimationCPP'
#          ani.source_files = 'MLN-iOS/MLN/Classes/MUIKit/Component/ObjectAnimation/Source/**/*.{h,c,cpp}'
#          ani.compiler_flags = '-x objective-c++'
#          ani.dependency 'ArgoUI/Core'
#        end
    end
    
end
