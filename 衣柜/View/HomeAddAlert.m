//
//  HomeAddAlert.m
//  衣柜
//
//  Created by lichanghong on 12/8/17.
//  Copyright © 2017 lichanghong. All rights reserved.
//

#import "HomeAddAlert.h"
#import <CHBaseUtil.h>


@implementation HomeAddAlert
+ (void)alertInVC:(UIViewController *)vc success:(void (^)(void))success
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"添加衣架" preferredStyle:UIAlertControllerStyleAlert];
    //增加取消按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    //增加确定按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //获取第1个输入框；
        UITextField *userNameTextField = alertController.textFields.firstObject;
        if (userNameTextField.text.length>100) {
            [[UIApplication sharedApplication].keyWindow makeToast:@"保存失败，名字太长"];
            return;
        }
        NSLog(@"衣架名称 = %@",userNameTextField.text);
        [[UIApplication sharedApplication].keyWindow  makeToast:@"保存成功"];
        success();
    }]];
    
    //定义第一个输入框；
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"给衣架起一个名称";
    }];
    
    [vc presentViewController:alertController animated:true completion:nil];
}
@end
