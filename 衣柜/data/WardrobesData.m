//
//  WardrobesData.m
//  衣柜
//
//  Created by lichanghong on 12/11/17.
//  Copyright © 2017 lichanghong. All rights reserved.
//

#import "WardrobesData.h"
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

+ (NSString *)cachePath
{
     return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory
                                                             , NSUserDomainMask
                                                             , YES) lastObject];
}

+ (void)addWardrobesItemWithTitle:(NSString *)title
{
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        WardrobesEntity *entity = [WardrobesEntity MR_createEntityInContext:localContext];
        entity.index = (int32_t)[WardrobesData count];
        entity.title = title;
    }];
}

+ (void)removeWardrobesItemAtIndexPath:(NSIndexPath *)indexPath
{
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index = %d",indexPath.row];
        WardrobesEntity *entity = [[WardrobesEntity MR_findAllWithPredicate:predicate]lastObject];
        [entity MR_deleteEntity];
        
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"index > %d",indexPath.row];
        NSArray *entitys = [WardrobesEntity MR_findAllWithPredicate:predicate1];
        for (WardrobesEntity *en in entitys) {
            en.index-=1;
        }
        
    }];
}

@end
