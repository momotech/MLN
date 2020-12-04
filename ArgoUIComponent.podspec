#
# Be sure to run `pod lib lint ArgoUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'ArgoUIComponent'
    s.version          = '0.1.4'
    s.summary          = 'components of ArgoUI'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = <<-DESC
    components of ArgoUI
    DESC
    
    s.homepage         = 'https://mln.immomo.com'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = 'MoMo'
    s.source           = { :git => 'https://github.com/momotech/MLN.git', :tag => 'ArgoUIComponent/' + s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
    s.ios.deployment_target = '8.0'
#    s.libraries = 'c++'
    s.requires_arc = true
    # s.resource = 'MLN-iOS/MLN/Resource/ArgoUISystem.bundle'
    s.dependency  'ArgoUI'
#    s.source_files = 'MLN-iOS/MLN/Classes/ArgoUIComponent/**/*.{h,m,c}'
#    s.public_header_files = 'MLN-iOS/MLN/Classes/ArgoUIComponent/**/*.h'

    s.subspec 'ErrorHandler' do |c|
        c.name = 'ErrorHandler'
        c.source_files = 'MLN-iOS/MLN/Classes/ArgoUIComponent/ErrorHandler/**/*.{h,m,c}'
        c.public_header_files = 'MLN-iOS/MLN/Classes/ArgoUIComponent/ErrorHandler/**/*.h'
    end
end
