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
#import <QN_GTM_Base64.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <QiniuSDK.h>
#import <AFNetworking.h>

@implementation WardrobesEntityTable
@end
@implementation DetailEntityTable
@end

@interface WardrobesData()
@property (nonatomic,strong) QNUploadManager *uploadManager;
@end
@implementation WardrobesData

- (QNUploadManager *)uploadManager
{
    if (!_uploadManager) {
        _uploadManager = [[QNUploadManager alloc]init];
    }
    return _uploadManager;
}

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

+ (NSString *)allDataPath
{
    NSString *cachePath = [[WardrobesData cachePath] stringByAppendingPathComponent:@"allData"];
    NSLog(@"alldatapath=%@",cachePath);
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //把刚刚图片转换的data对象拷贝至沙盒中并保存为image.png
    BOOL isDic=NO;
    if(!([fileManager fileExistsAtPath:cachePath isDirectory:&isDic] && isDic))
    {
        [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *alldataPath = [cachePath stringByAppendingPathComponent:@"alldata"];
    return alldataPath;
}

+ (void)saveAllData
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray *arr = [self entities];
    for (WardrobesEntity *wardrabes in arr) {
        WardrobesEntityTable *wet = [[WardrobesEntityTable alloc]init];
        wet.index = wardrabes.index;
        wet.title = wardrabes.title;
        wet.dets  = [NSMutableArray array];
        for (DetailEntity *detail in wardrabes.detail) {
            DetailEntityTable *det = [[DetailEntityTable alloc]init];
            det.index = detail.index;
            det.imagePath = detail.imagePath;
            [wet.dets addObject: det];
        }
        [result addObject:wet];
    }
    
    if(![NSKeyedArchiver archiveRootObject:result toFile:[self allDataPath]])
    {
        NSLog(@"error writeToFile...");
    }
}


static NSString *scope=@"cloth/images";
static NSString *AK=@"Z8K4P0VVPHnNTdmDt_ZKFjtsUE73vFVDNUoPyvXX";
static NSString *SK=@"aldz87U2-FVDfdDlbjiM_fL-drOx0w4No_5k2pLU";
static NSString *QN_DOMAIN=@"http://p0zyyhsy8.bkt.clouddn.com";

+ (void)postAllDataToServer
{
    NSString *filePath = [self allDataPath];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSString *token = [self token];
    [[[self wardrobeData] uploadManager] putData:data key:@"sqlite/alldata" token:token
              complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                  NSLog(@"%@", info);
                  NSLog(@"%@", resp);
              } option:nil];
}
+ (void)postAllUnuploadImageToServer
{
    [self postAllDataToServer];
    for (WardrobesEntity*wardrobes in [self entities]) {
        for (DetailEntity *detail in wardrobes.detail) {
            if (detail.uploaded==true) {
                NSLog(@"uploaded....");
                return;
            }
            NSString *imageP = [[self cachePath] stringByAppendingPathComponent:detail.imagePath];
           NSData *data = [NSData dataWithContentsOfFile:imageP];
            NSString *token = [self token];
            NSString *key = detail.imagePath;
            [[[self wardrobeData] uploadManager] putData:data key:key token:token
                                                complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                                                    NSLog(@"%@", info);
                                                    NSLog(@"%@", resp);
                                                    detail.uploaded = true;
                                                    [detail.managedObjectContext MR_saveToPersistentStoreAndWait];
                                                } option:nil];
        }
    }
}

+ (void)restoreAllSourcesSuccess:(void(^)(void))success
{
    //clear sqlite
    [WardrobesEntity MR_truncateAll];
    //clear localdata
    NSString *filePath = [self allDataPath];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    //download local data from server
    NSString *alldataURL = [QN_DOMAIN stringByAppendingPathComponent:@"sqlite/alldata"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    AFHTTPResponseSerializer *serializer =  [AFHTTPResponseSerializer serializer];
    serializer.acceptableContentTypes = [NSSet setWithObject:@"application/octet-stream"];
    manager.responseSerializer = serializer;
     [manager GET:alldataURL parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if(![NSKeyedArchiver archiveRootObject:responseObject toFile:[self allDataPath]])
        {
            NSLog(@"error writeToFile...");
        }
        else
        {
            NSMutableArray *result = [NSKeyedUnarchiver unarchiveObjectWithData:responseObject];
            if (result && result.count>0) {
                for (WardrobesEntityTable *wardrobes in result) {
                    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
                        WardrobesEntity *entity = [WardrobesEntity MR_createEntityInContext:localContext];
                        entity.index = wardrobes.index;
                        entity.title = wardrobes.title;
                        entity.detail = [NSSet set];
                        if (wardrobes.dets && wardrobes.dets.count>0) {
                            for (DetailEntityTable *table in wardrobes.dets) {
                                DetailEntity *detail = [DetailEntity MR_createEntityInContext:localContext];
                                detail.imagePath = table.imagePath;
                                detail.index = table.index;
                                [entity addDetailObject:detail];
                            }
                        }
                    }];
                }
                [self downloadImageSuccess:success];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}
+ (void)downloadImageSuccess:(void(^)(void))success
{
    //download image on server
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
    serializer.acceptableContentTypes =  [NSSet setWithObject:@"image/png"];
    manager.responseSerializer = serializer;
    
    
    NSArray *entities = [WardrobesData entities];
    NSFileManager *fileManager = [NSFileManager defaultManager];

//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    for (WardrobesEntity *entity in entities) {
        for (DetailEntity *detail in entity.detail) {
            NSString *imageP = [[self cachePath] stringByAppendingPathComponent:detail.imagePath];
            NSString *imageurl = [QN_DOMAIN stringByAppendingPathComponent:detail.imagePath];

            if(([fileManager fileExistsAtPath:imageP isDirectory:nil]))
            {
                continue;
            }
            
            NSURL *URL = [NSURL URLWithString:imageurl];
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            
            NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
                return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                NSLog(@"File downloaded to: %@", filePath);
                NSString *cachePath = [[WardrobesData cachePath] stringByAppendingPathComponent:@"images"];
                NSLog(@"cachepath=%@",cachePath);
                //文件管理器
                //把刚刚图片转换的data对象拷贝至沙盒中并保存为image.png
                BOOL isDic=NO;
                if(!([fileManager fileExistsAtPath:cachePath isDirectory:&isDic] && isDic))
                {
                    [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
                }
               NSData *data = [NSData dataWithContentsOfURL:filePath];
                if ([fileManager createFileAtPath:imageP contents:data attributes:nil]) {
                    success();
                }
//                dispatch_semaphore_signal(semaphore);

            }];
            [downloadTask resume];
//            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            NSLog(@"wait....");
        }
    }
    success();
}
+ (NSString *)token
{
    NSMutableDictionary *authInfo = [NSMutableDictionary dictionary];
    [authInfo setObject:scope forKey:@"scope"];
    [authInfo setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970] + 1 * 24 * 3600]
     forKey:@"deadline"];
    NSData *jsonData =
    [NSJSONSerialization dataWithJSONObject:authInfo options:NSJSONWritingPrettyPrinted error:nil];
    NSString *encodedString = [[self wardrobeData] urlSafeBase64Encode:jsonData];
    NSString *encodedSignedString = [[self wardrobeData] HMACSHA1:SK text:encodedString];
    NSString *token = [NSString stringWithFormat:@"%@:%@:%@", AK, encodedSignedString, encodedString];
    return token;

}

- (NSString *)HMACSHA1:(NSString *)key text:(NSString *)text {
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];
    
    char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    NSString *hash = [self urlSafeBase64Encode:HMAC];
    return hash;
}

- (NSString *)urlSafeBase64Encode:(NSData *)text {
    NSString *base64 =
    [[NSString alloc] initWithData:[QN_GTM_Base64 encodeData:text] encoding:NSUTF8StringEncoding];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    return base64;
}


+ (NSArray *)localEntities
{
    NSArray *arr = [NSKeyedUnarchiver unarchiveObjectWithFile:[self allDataPath]];
    return arr;
}

@end
