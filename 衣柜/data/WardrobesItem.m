
//
//  WardrobesItem.m
//  衣柜
//
//  Created by lichanghong on 12/11/17.
//  Copyright © 2017 lichanghong. All rights reserved.
//

#import "WardrobesItem.h"

@implementation WardrobeItemDetail


@end

@implementation WardrobesItem

+ (WardrobesItem *)addWardrobesItemWithTitle:(NSString *)title index:(NSInteger)index
{
    WardrobesItem *item = [[WardrobesItem alloc]init];
    item.title = title;
    item.index = index;
    item.createTime = time(NULL);
    item.wardrobesPaths = [NSMutableArray array];
    return item;
}

@end
