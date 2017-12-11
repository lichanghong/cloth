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
@property (nonatomic,strong)NSMutableArray *wardrobes;
+ (WardrobesData *)addWardrobesItemWithTitle:(NSString *)title;

+ (NSString *)pathOfWardrobeData;

+ (instancetype)wardrobeData;



@end
