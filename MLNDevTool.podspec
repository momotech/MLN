#
# Be sure to run `pod lib lint MLNCore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'MLNDevTool'
    s.version          = '0.1.7.1'
    s.summary          = 'Debug Tool of MLN.'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = <<-DESC
    Debug Tool of MLN.
    DESC
    
    s.homepage         = 'https://mln.immomo.com'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = 'MoMo'
    s.source           = { :git => 'https://github.com/momotech/MLN.git', :tag => 'devtool-' + s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
    s.ios.deployment_target = '8.0'
    s.libraries = 'z'
    s.requires_arc = true
    s.public_header_files = 'MLN-iOS/MLNDevTool/Classes/*.h'
    
    s.subspec 'Protobuf' do |pb|
      pb.name = 'Protobuf'
      pb.source_files = 'MLN-iOS/MLNDevTool/Classes/Protobuf/**/*.{h,m,c,a}'
      pb.vendored_libraries = 'MLN-iOS/MLNDevTool/Classes/Protobuf/**/*.a'
      pb.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '"$(SRCROOT)/../../MLNDevTool/Classes/Protobuf/include" "$(SRCROOT)/MLNDevTool/MLN-iOS/MLNDevTool/Classes/Protobuf/include"'
      }
    end
    
    s.subspec 'Conn' do |conn|
      conn.name = 'Conn'
      conn.framework = 'Foundation', 'UIKit', 'CoreGraphics', 'AVFoundation'
      conn.source_files = 'MLN-iOS/MLNDevTool/Classes/Conn/**/*.{h,m,c}'
      conn.public_header_files = 'MLN-iOS/MLNDevTool/Classes/Conn/**/*.h'
      conn.dependency  'MLNDevTool/Protobuf'
    end
    
    s.subspec 'DevTool' do |d|
      d.name = 'DevTool'
      d.source_files = 'MLN-iOS/MLNDevTool/Classes/DevTool/**/*.{h,m,c}'
      d.public_header_files = 'MLN-iOS/MLNDevTool/Classes/DevTool/**/*.h'
      d.resource_bundles = {
        'MLNDevTool_Util' => 'MLN-iOS/MLNDevTool/Classes/DevTool/Util/**/Assets/*.{png,lua,xib,storyboard}',
        'MLNDevTool_UI' => 'MLN-iOS/MLNDevTool/Classes/DevTool/UI/**/Assets/*.{png,xib}'
      }
      d.dependency 'MLN', '~> 1.0.0.2'
      d.dependency  'MLNDevTool/Conn'
    end

    s.subspec 'Performance' do |perf|
      perf.name = 'Performance'
      perf.framework = 'Foundation', 'UIKit', 'CoreGraphics', 'AVFoundation'
      perf.source_files = 'MLN-iOS/MLNDevTool/Classes/Performance/**/*.{h,m,c}'
      perf.public_header_files = 'MLN-iOS/MLNDevTool/Classes/Performance/**/*.h'
    end
        
    s.subspec 'Offline' do |o|
        o.name = 'Offline'
        o.source_files = 'MLN-iOS/MLNDevTool/Classes/Offline/**/*.{h,m,c}'
        o.public_header_files = 'MLN-iOS/MLNDevTool/Classes/Offline/**/*.h'
        o.resource_bundles = {
          'MLNDevTool_Offline' => 'MLN-iOS/MLNDevTool/Classes/Offline/**/Assets/*.{png,lua,xib}'
        }
        o.dependency  'MLNDevTool/DevTool'
        o.dependency 'MLN', '~> 1.0.0.2'
    end
    
    s.subspec 'HotReload' do |h|
        h.name = 'HotReload'
        h.framework = 'Foundation', 'UIKit'
        h.source_files = 'MLN-iOS/MLNDevTool/Classes/HotReload/**/*.{h,m,c}'
        h.public_header_files = 'MLN-iOS/MLNDevTool/Classes/HotReload/**/*.h'
        h.dependency  'MLNDevTool/DevTool'
        h.dependency  'MLNDevTool/Conn'
        h.resource_bundles = {
          'MLNDevTool_HotReload' => 'MLN-iOS/MLNDevTool/Classes/HotReload/**/Assets/*.{png,xib}'
        }
        h.dependency 'MLN', '~> 1.0.0.2'
    end
    
end
