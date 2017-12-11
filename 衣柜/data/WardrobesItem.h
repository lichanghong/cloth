//
//  WardrobesItem.h
//  衣柜
//
//  Created by lichanghong on 12/11/17.
//  Copyright © 2017 lichanghong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeyedArchiveObject.h"

@interface WardrobeItemDetail : KeyedArchiveObject
@property (nonatomic,strong)NSString *brief;
@property (nonatomic,strong)NSString *path;

@end


@interface WardrobesItem : KeyedArchiveObject
@property (nonatomic,assign)NSInteger createTime;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSMutableArray *wardrobesPaths;

+ (WardrobesItem *)addWardrobesItemWithTitle:(NSString *)title;

@end
