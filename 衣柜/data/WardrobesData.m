//
//  WardrobesData.m
//  衣柜
//
//  Created by lichanghong on 12/11/17.
//  Copyright © 2017 lichanghong. All rights reserved.
//

#import "WardrobesData.h"
#import "WardrobesItem.h"

@implementation WardrobesData

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.wardrobes = [NSMutableArray array];
    }
    return self;
}

+ (instancetype)wardrobeData
{
    static WardrobesData *single=nil;
    @synchronized(self){
        single = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathOfWardrobeData]];
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

+ (WardrobesData *)addWardrobesItemWithTitle:(NSString *)title
{
    WardrobesData *data = [WardrobesData wardrobeData];
    WardrobesItem *item = [WardrobesItem addWardrobesItemWithTitle:title];
    [data.wardrobes addObject:item];
    if ([NSKeyedArchiver archiveRootObject:data toFile:[self pathOfWardrobeData]]) {
        return data;
    }
    else NSLog(@"addWardrobesItemWithTitle:%@ error",title);
    return nil;
}

@end
