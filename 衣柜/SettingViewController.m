//
//  SettingViewController.m
//  衣柜
//
//  Created by lichanghong on 12/20/17.
//  Copyright © 2017 lichanghong. All rights reserved.
//

#import "SettingViewController.h"
#import "WardrobesData.h"
#import <UIView+Toast.h>

@interface SettingViewController ()

@property (weak, nonatomic) IBOutlet UIButton *upload;

@property (weak, nonatomic) IBOutlet UIButton *local;

@property (weak, nonatomic) IBOutlet UIButton *setting;

@property (weak, nonatomic) IBOutlet UIButton *clear;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)handleAction:(id)sender {
    if (sender == self.clear) {
        //清除未同步的垃圾图片
    }
    else if (sender == self.local)
    {
        //同步到本地
        [WardrobesData restoreAllSourcesSuccess:^{
            [self.view makeToast:@"同步成功"];
        }];
    }
    else if (sender == self.upload)
    {
        [WardrobesData postAllUnuploadImageToServerSuccess:^{
            [self.view makeToast:@"上传成功"];
        }];
    }
    else if (sender == self.setting)
    {
        //配置服务器
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
