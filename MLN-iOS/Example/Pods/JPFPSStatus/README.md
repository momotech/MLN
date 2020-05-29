






# JPFPSStatus
[![Pod Version](http://img.shields.io/cocoapods/v/JPFPSStatus.svg?style=flat)](http://cocoadocs.org/docsets/JPFPSStatus/)
[![Pod Platform](http://img.shields.io/cocoapods/p/JPFPSStatus.svg?style=flat)](http://cocoadocs.org/docsets/JPFPSStatus/)
[![Pod License](http://img.shields.io/cocoapods/l/JPFPSStatus.svg?style=flat)](https://opensource.org/licenses/MIT)

[README 中文](https://github.com/joggerplus/JPFPSStatus/blob/master/README_Chinese.md)

Show FPS Status on StatusBar

#### Podfile

```ruby
platform :ios, '7.0'
pod 'JPFPSStatus', '~> 0.1'
```



#### Instruction
Note：Use JPFPSStatus in DEBUG mode

add the code in AppDelegate.m    

<pre>
#import "JPFPSStatus.h"
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
#if defined(DEBUG)||defined(_DEBUG)
    [[JPFPSStatus sharedInstance] open];
#endif
    return YES;
}

</pre>

<pre>
#if defined(DEBUG)||defined(_DEBUG)
	[[JPFPSStatus sharedInstance] openWithHandler:^(NSInteger fpsValue) {
		NSLog(@"fpsvalue %@",@(fpsValue));
	}];
#endif

</pre>


<pre>
#if defined(DEBUG)||defined(_DEBUG)
    [[JPFPSStatus sharedInstance] close];
#endif
</pre>



<img  src="https://raw.githubusercontent.com/joggerplus/JPFPSStatus/master/JPFPSStatus/Resources/jpfpsstatus1.jpg" width="320" height="570">


#### Licenses

All source code is licensed under the [MIT License](https://github.com/joggerplus/JPFPSStatus/blob/master/LICENSE).
