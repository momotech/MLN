//
//  MLNDataBindArrayViewController.m
//  LuaNative
//
//  Created by Dai Dongpeng on 2020/5/12.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNDataBindArrayViewController.h"
#import "MLNDataBindModel.h"
#import "MLNUIViewController+DataBinding.h"

@interface MLNDataBindArrayViewController ()
@property (nonatomic, strong) MLNDataBindArrayModel *model;
@end

@implementation MLNDataBindArrayViewController

- (instancetype)init
{
    NSString *demoName = @"layout_forEach.lua";
    NSString *path = [[NSBundle mainBundle] pathForResource:@"inner_demo" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    
    self = [super initWithEntryFileName:demoName bundle:bundle];
    if (self) {
        self.model = [MLNDataBindArrayModel testModel];
        [self bindData:self.model forKey:@"userDataModel"];
    }
    return self;
}

- (void)changeModel {
    static NSUInteger index = 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self changeModel];
        NSUInteger i = index++ % self.model.source.count;
        printf("i is %zd \n",i);
        MLNDataBindModel *m = [self.model.source objectAtIndex:i];
        m.name = [NSString stringWithFormat:@"change to %lu",(unsigned long)index];
    });
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self changeModel];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end


/*
 
 --
 --  Lua - UI
 --  project[ MLNUIDemo ]
 --  package[  ]
 --  forEachView.llua
 --  Created by deepak on 2020/04/13 19:53.
 --  Copyright © 2020. All rights reserved.
 --



 model(userDataModel)

 myLabel(item) {
     VStack()
     .subs(
         Label(item.name)
         --    .watch(item.name_str, function()
         --    self.fontSize(self.fontSize() + 5)
         --end)
         ,
         Label(item.title)
         .onClick(function()
             item.name = "change"
         end)
     )
     .mainAxisAlignment(MainAxisAlignment.SPACE_EVENLY)
 }



 ---
 --- UI
 ui = {
     --- layout views

     HStack()
     .bgColor(Color(255, 0, 0, .2))
     .subs(
             Label(userDataModel.name),
             userDataModel.source.forEach(function(i,item)
                     return myLabel(item)
             end)

             --myLabel(userDataModel)
             --,
             --myLabel(userDataModel)

     )
     .width(MeasurementType.MATCH_PARENT)
     .height(88)
     .gravity(Gravity.CENTER_VERTICAL)
     .mainAxisAlignment(MainAxisAlignment.SPACE_BETWEEN)
     .crossAxisAlignment(CrossAxisAlignment.CENTER)
     .onClick(function()
         local s = {}
         for i = 1, 3 do
             local t  = {}
             t.name = "change "..i
             s[i] = t
         end
         userData.source = s
     end)
 }

 ---
 --- preview
 function preview()

     userDataModel.name = "hello"

     local source = {}
     for i = 1, 3 do
         local t  = {}
         t.name = "subs "..i
         t.title = "aaaa "..i
         t.click = 1
         source[i] = t
     end

     userDataModel.source = source
     userDataModel.title = "title2"
 end
 */
