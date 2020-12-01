#
# Be sure to run `pod lib lint ArgoUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'ArgoAnimation'
    s.version          = '0.1.1'
    s.summary          = 'Animation Component'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = <<-DESC
    Animation Component
    DESC
    
    s.homepage         = 'https://mln.immomo.com'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = 'MoMo'
    s.source           = { :git => 'https://github.com/momotech/MLN.git', :tag => 'ArgoAnimation/' + s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
    s.ios.deployment_target = '8.0'
    s.libraries = 'c++'
    s.requires_arc = true
    # s.resource = 'MLN-iOS/MLN/Resource/ArgoUISystem.bundle'
    s.source_files = 'MLN-iOS/MLN/Classes/Animation/MLAnimator/**/*.{h,c,cpp,m,mm}'
#    s.public_header_files = 'MLN-iOS/MLN/Classes/ArgoAnimation/**/*.h'

    s.subspec 'AnimationCPP' do |ani|
        ani.name = 'AnimationCPP'
        ani.source_files = 'MLN-iOS/MLN/Classes/Animation/CPP/**/*.{h,c,cpp,m,mm}'
        ani.compiler_flags = '-x objective-c++'
    end
end
