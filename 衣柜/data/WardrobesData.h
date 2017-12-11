//
//  WardrobesData.h
//  衣柜
//
//  Created by lichanghong on 12/11/17.
//  Copyright © 2017 lichanghong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeyedArchiveObject.h"

@interface WardrobesData : KeyedArchiveObject

+ (void)addWardrobesItemWithTitle:(NSString *)title;

+ (NSInteger)count;
+ (NSArray *)entities;
+ (NSString *)pathOfWardrobeData;

+ (instancetype)wardrobeData;



@end
