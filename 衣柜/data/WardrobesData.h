//
//  WardrobesData.h
//  衣柜
//
//  Created by lichanghong on 12/11/17.
//  Copyright © 2017 lichanghong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WardrobesData : NSObject
//添加新的衣架调用
+ (void)addWardrobesItemWithTitle:(NSString *)title;
+ (void)removeWardrobesItemAtIndexPath:(NSIndexPath *)indexPath;

+ (NSInteger)count;
+ (NSArray *)entities;
+ (NSString *)cachePath;

+ (instancetype)wardrobeData;



//同步到云端




@end
