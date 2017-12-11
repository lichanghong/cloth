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
@property (nonatomic,strong)NSString *imagePath;

+ (instancetype)createDetailWithInfo:(NSDictionary<NSString *,id> *)info ImageData:(NSData *)data;

 
@end


@interface WardrobesItem : KeyedArchiveObject
@property (nonatomic,assign)NSInteger index;
@property (nonatomic,assign)NSInteger createTime;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSMutableArray *wardrobesPaths;

+ (WardrobesItem *)addWardrobesItemWithTitle:(NSString *)title index:(NSInteger)index;

@end
