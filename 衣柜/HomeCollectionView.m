//
//  HomeCollectionView.m
//  衣柜
//
//  Created by lichanghong on 12/5/17.
//  Copyright © 2017 lichanghong. All rights reserved.
//

#import "HomeCollectionView.h"
#import "CollectionViewCell.h"
#import <CHBaseUtil.h>
#import "WardrobesData.h"
#import "WardrobesItem.h"
#import<CommonCrypto/CommonDigest.h>
#import "WardrobesEntity+CoreDataClass.h"
#import <MagicalRecord/MagicalRecord.h>
#import "DetailEntity+CoreDataClass.h"

@interface HomeCollectionView()
@property (nonatomic,strong)WardrobesEntity *takePhotoItem;
@end

@implementation HomeCollectionView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.delegate = self;
        self.dataSource = self;

    }
    return self;
}
 

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *entities = [WardrobesData entities];
    WardrobesEntity *entity = [entities objectAtIndex:collectionView.tag];
    NSUInteger count = entity.detail.count;
    return  count == 0 ? 1:count+1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *collVC = [collectionView dequeueReusableCellWithReuseIdentifier:[CollectionViewCell identifier] forIndexPath:indexPath];
    NSArray *entities = [WardrobesData entities];
    WardrobesEntity *entity = [entities objectAtIndex:collectionView.tag];

    if (entity.detail.count<=indexPath.item) {
        collVC.imageView.image = [UIImage imageNamed:@"add"];
    }
    else {
        if (entity.detail && entity.detail.count > indexPath.row) {
            DetailEntity *detail = entity.detail.allObjects[indexPath.row];
            if (collVC) {
                NSString *imageP = [[WardrobesData cachePath] stringByAppendingPathComponent:detail.imagePath];
                UIImage *image = [UIImage imageWithContentsOfFile:imageP];
                collVC.imageView.image = image;
            }
        }
    }
    return collVC;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *entities = [WardrobesData entities];
    if (entities.count<collectionView.tag) {
        return;
    }
    WardrobesEntity *entity = [entities objectAtIndex:collectionView.tag];
    NSSet *details = entity.detail;
    NSUInteger count = details.count;
    if (indexPath.item == count) {
        self.takePhotoItem = entity;
        [self takePhoto];
    }
    else{
        DetailEntity *detail = [details.allObjects objectAtIndex:indexPath.item];

    }
}


- (void)takePhoto
{
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    __weak HomeCollectionView *weakself = self;
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
        
    }];
    
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"打开相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        [rootVC presentViewController:imagePicker animated:YES completion:nil];
    }];
    
    UIAlertAction *picture = [UIAlertAction actionWithTitle:@"相册中选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            pickerImage.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerImage.sourceType];
            
        }
        pickerImage.delegate = self;
        pickerImage.allowsEditing = NO;
        [rootVC presentViewController:pickerImage animated:YES completion:nil];
    }];
    [alertVc addAction:cancle];
    [alertVc addAction:camera];
    [alertVc addAction:picture];
    [rootVC presentViewController:alertVc animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData *data;
        if (UIImagePNGRepresentation(image) ==nil)
        {
            data = UIImageJPEGRepresentation(image,1.0);
        }
        else
        {
            data = UIImagePNGRepresentation(image);
        }
        
        
        NSArray *entities = [WardrobesData entities];
        WardrobesEntity *entity = [entities objectAtIndex:self.tag];
        NSString *imagePath = [HomeCollectionView createImageWithInfo:info ImageData:data];
        __weak HomeCollectionView *weakself = self;
        
        DetailEntity *detail = [DetailEntity MR_createEntityInContext:[entity managedObjectContext]];
        [detail setBrief:@""];
        detail.imagePath = [[imagePath componentsSeparatedByString:@"Caches/"] lastObject];
        [entity addDetailObject:detail];
        [entity.managedObjectContext MR_saveToPersistentStoreAndWait];

        [weakself reloadData];

        //关闭相册界面
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

+ (NSString *)createImageWithInfo:(NSDictionary<NSString *,id> *)info ImageData:(NSData *)data
{
    NSString *cachePath = [[WardrobesData cachePath] stringByAppendingPathComponent:@"images"];
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //把刚刚图片转换的data对象拷贝至沙盒中并保存为image.png
    BOOL isDic=NO;
    if(!([fileManager fileExistsAtPath:cachePath isDirectory:&isDic] && isDic))
    {
        [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *name = [self md5:[[info objectForKey:@"UIImagePickerControllerImageURL"]
                                absoluteString]];
    name = [NSString stringWithFormat:@"/%ld_%@.png",time(NULL),name];
    NSString *imagePath = [cachePath stringByAppendingString:name];
    if ([fileManager createFileAtPath:imagePath contents:data attributes:nil]) {
        return imagePath;
    }
    return nil;
}


+ (NSString *) md5:(NSString *) input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
