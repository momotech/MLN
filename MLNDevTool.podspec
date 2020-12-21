#
# Be sure to run `pod lib lint MLNCore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'MLNDevTool'
    s.version          = '0.2.10'
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
    s.module_map = 'MLN-iOS/MLNDevTool/Classes/module.modulemap'
    s.ios.deployment_target = '8.0'
    s.libraries = 'z', 'c++'
    
    s.subspec 'Header' do |s|
        s.name = 'Header'
        s.source_files = 'MLN-iOS/MLNDevTool/Classes/MLNDevTool.h'
    end
    
    s.subspec 'MLNProtobuf' do |pb|
        pb.name = 'MLNProtobuf'
        pb.source_files = 'MLN-iOS/MLNDevTool/Classes/MLNProtobuf/**/*.{h,m}'
        pb.private_header_files = 'MLN-iOS/MLNDevTool/Classes/MLNProtobuf/**/*.h'
        pb.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1' }
        pb.dependency 'MLNDevTool/Header'
        pb.dependency 'Protobuf'
    end
    
    s.subspec 'Conn' do |conn|
        conn.name = 'Conn'
        conn.framework = 'Foundation', 'UIKit', 'CFNetwork'
        conn.source_files = 'MLN-iOS/MLNDevTool/Classes/Conn/**/*.{h,m}'
        conn.private_header_files = 'MLN-iOS/MLNDevTool/Classes/Conn/**/*.h'
        conn.dependency 'MLNDevTool/Header'
        conn.dependency 'MLNDevTool/MLNProtobuf'
    end
    
    s.subspec 'DevTool' do |d|
        d.name = 'DevTool'
        d.source_files = 'MLN-iOS/MLNDevTool/Classes/DevTool/**/*.{h,m,c}'
        d.private_header_files = 'MLN-iOS/MLNDevTool/Classes/DevTool/Util/DebugLib/**/*.h'
        d.framework = 'Foundation', 'UIKit', 'AVFoundation'
        d.resource_bundles = {
            'MLNDevTool_Util' => 'MLN-iOS/MLNDevTool/Classes/DevTool/Util/**/Assets/*.{png,lua,xib,storyboard}',
            'MLNDevTool_UI' => 'MLN-iOS/MLNDevTool/Classes/DevTool/UI/**/Assets/*.{png,xib}'
        }
        d.dependency 'MLNDevTool/Header'
        d.dependency 'MLNDevTool/Conn'
        d.dependency 'MLN'
        d.dependency 'ArgoUI'
    end

    s.subspec 'Performance' do |perf|
        perf.name = 'Performance'
        perf.framework = 'Foundation', 'UIKit'
        perf.source_files = 'MLN-iOS/MLNDevTool/Classes/Performance/**/*.{h,m,c}'
        perf.public_header_files = 'MLN-iOS/MLNDevTool/Classes/Performance/**/*.h'
        perf.dependency 'MLNDevTool/Header'
        perf.dependency 'ArgoUI'
    end
        
    s.subspec 'Offline' do |o|
        o.name = 'Offline'
        o.source_files = 'MLN-iOS/MLNDevTool/Classes/Offline/**/*.{h,m,c}'
        o.public_header_files = 'MLN-iOS/MLNDevTool/Classes/Offline/MLNOfflineViewController.h'
        o.resource_bundles = {
            'MLNDevTool_Offline' => 'MLN-iOS/MLNDevTool/Classes/Offline/**/Assets/*.{png,lua,xib}'
        }
        o.dependency 'MLNDevTool/Header'
        o.dependency 'MLNDevTool/DevTool'
        o.dependency 'MLN'
    end
    
    s.subspec 'HotReload' do |h|
        h.name = 'HotReload'
        h.framework = 'Foundation', 'UIKit'
        h.source_files = 'MLN-iOS/MLNDevTool/Classes/HotReload/**/*.{h,m,c}'
        h.public_header_files = 'MLN-iOS/MLNDevTool/Classes/HotReload/MLNHotReload.h',
                                'MLN-iOS/MLNDevTool/Classes/HotReload/UI/**/*.h'
        h.resource_bundles = {
            'MLNDevTool_HotReload' => 'MLN-iOS/MLNDevTool/Classes/HotReload/**/Assets/*.{png,xib}'
        }
        h.dependency 'MLNDevTool/Header'
        h.dependency 'MLNDevTool/DevTool'
        h.dependency 'MLNDevTool/Conn'
        h.dependency 'MLN'
        h.dependency 'ArgoUI'
    end
    
end
