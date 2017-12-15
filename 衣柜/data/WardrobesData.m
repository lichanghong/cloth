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
#import "DetailEntity+CoreDataClass.h"

@implementation WardrobesData

+ (NSInteger)count
{
    return [WardrobesEntity MR_countOfEntities];
}

+ (NSArray *)entities
{
   NSArray *entitys = [WardrobesEntity MR_findAllSortedBy:@"index"
                     ascending:YES];
//    for (WardrobesEntity *en in entitys) {
//        NSLog(@"%d",en.index);
//    }
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
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.index = %d",indexPath.section];
        NSArray *wardrobes = [WardrobesEntity MR_findAllWithPredicate:predicate];
        WardrobesEntity *entity = [wardrobes lastObject];
        //本地图片删除
        for (DetailEntity *detail in entity.detail) {
            NSString *imageP = [[self cachePath] stringByAppendingPathComponent:detail.imagePath];
            [[NSFileManager defaultManager] removeItemAtPath:imageP error:nil];
        }


        [entity MR_deleteEntityInContext:localContext];
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"SELF.index > %d",indexPath.section];
        NSArray *entitys = [WardrobesEntity MR_findAllWithPredicate:predicate1 inContext:localContext];
        for (WardrobesEntity *en in entitys) {
            en.index-=1;
        }
    }];
    
//   int count = [self entities].count;
//    NSLog(@"count=%d",count);
}

@end
