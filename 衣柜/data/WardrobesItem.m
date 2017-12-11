
//
//  WardrobesItem.m
//  衣柜
//
//  Created by lichanghong on 12/11/17.
//  Copyright © 2017 lichanghong. All rights reserved.
//

#import "WardrobesItem.h"

@implementation WardrobeItemDetail

+ (instancetype)createDetailWithInfo:(NSDictionary<NSString *,id> *)info ImageData:(NSData *)data
{
    WardrobeItemDetail *detail = [[WardrobeItemDetail alloc]init];
    detail.brief = @"";
    detail.imagePath = [self createImageWithInfo:info ImageData:data];
    return detail;
}

+ (NSString *)createImageWithInfo:(NSDictionary<NSString *,id> *)info ImageData:(NSData *)data
{
    NSString *DocumentsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)firstObject]
                               stringByAppendingPathComponent:@"images"];
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //把刚刚图片转换的data对象拷贝至沙盒中并保存为image.png
    BOOL isDic=NO;
    if(!([fileManager fileExistsAtPath:DocumentsPath isDirectory:&isDic] && isDic))
    {
        [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *name = [self md5:[[info objectForKey:@"UIImagePickerControllerImageURL"]
                                absoluteString]];
    name = [NSString stringWithFormat:@"/%ld_%@.png",time(NULL),name];
    NSString *imagePath = [DocumentsPath stringByAppendingString:name];
    if ([fileManager createFileAtPath:imagePath contents:data attributes:nil]) {
        return imagePath;
    }
    return nil;
}

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
