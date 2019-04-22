#
# Be sure to run `pod lib lint AMKBundleSettingsManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'AMKBundleSettingsManager'
    s.version          = '0.1.0'
    s.summary          = 'AMKBundleSettingsManager source code.'
    s.description      = <<-DESC
                         AMKBundleSettingsManager source code , ect.
                         DESC
    s.homepage         = 'https://github.com/AndyM129/AMKBundleSettingsManager'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Andy' => 'andy_m129@163.com' }
    s.source           = { :git => 'https://github.com/AndyM129/AMKBundleSettingsManager.git', :tag => s.version.to_s }
    s.ios.deployment_target = '8.0'
    s.source_files = 'AMKBundleSettingsManager/Classes/*.{h,m}'
end
