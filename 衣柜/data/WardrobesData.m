//
//  WardrobesData.m
//  衣柜
//
//  Created by lichanghong on 12/11/17.
//  Copyright © 2017 lichanghong. All rights reserved.
//

#import "WardrobesData.h"
#import "WardrobesItem.h"
#import "WardrobesEntity+CoreDataClass.h"
#import <MagicalRecord/MagicalRecord.h>

@implementation WardrobesData

+ (NSInteger)count
{
    return [WardrobesEntity MR_countOfEntities];
}

+ (NSArray *)entities
{
   NSArray *entitys = [WardrobesEntity MR_findAllSortedBy:@"index"
                     ascending:YES];
    return entitys;
}

+ (instancetype)wardrobeData
{
    static WardrobesData *single=nil;
    @synchronized(self){
        if (!single) {
            single = [[WardrobesData alloc]init];
        }
    }
    return single;
}

+ (NSString *)pathOfWardrobeData
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    NSString *pathDoc = [docPath stringByAppendingPathComponent:@"wardrobeData"];
    if (![[NSFileManager defaultManager]fileExistsAtPath:pathDoc]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:pathDoc withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSString stringWithFormat:@"%@/wardrobe.archiver",pathDoc];
}

+ (void)addWardrobesItemWithTitle:(NSString *)title
{
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        WardrobesEntity *entity = [WardrobesEntity MR_createEntityInContext:localContext];
        entity.index = (int32_t)[WardrobesData count];
        entity.title = title;
    }];
}

@end
