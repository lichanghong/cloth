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
+ (void)alertInVC:(UIViewController *)vc success:(void (^)(NSString *title))success
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
            [[UIApplication sharedApplication].keyWindow makeToast:@"衣架创建失败，名字太长"];
            return;
        }
        [[UIApplication sharedApplication].keyWindow  makeToast:@"衣架创建成功"];
        success(userNameTextField.text);
    }]];
    
    //定义第一个输入框；
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"给衣架起一个名称";
    }];
    
    [vc presentViewController:alertController animated:true completion:nil];
}
@end
