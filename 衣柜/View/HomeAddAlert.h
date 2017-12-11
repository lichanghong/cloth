//
//  HomeAddAlert.h
//  衣柜
//
//  Created by lichanghong on 12/8/17.
//  Copyright © 2017 lichanghong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HomeAddAlert : NSObject

+ (void)alertInVC:(UIViewController *)vc success:(void (^)(NSString *title))success;

@end
