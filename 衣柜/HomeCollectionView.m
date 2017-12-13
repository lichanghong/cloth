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
#import<CommonCrypto/CommonDigest.h>
#import "WardrobesEntity+CoreDataClass.h"
#import <MagicalRecord/MagicalRecord.h>
#import "DetailEntity+CoreDataClass.h"
#import "UIImage+Orientation.h"
#import <KSPhotoBrowser.h>
#import <TZImagePickerController.h>


@interface HomeCollectionView()<TZImagePickerControllerDelegate>
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
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    WardrobesEntity *entity = [entities objectAtIndex:collectionView.tag];
    NSSet *details = entity.detail;
    NSUInteger count = details.count;
    if (indexPath.item == count) {
        self.takePhotoItem = entity;
        [self takePhoto];
    }
    else{
        NSMutableArray *items = @[].mutableCopy;
        for (int i=0; i<details.allObjects.count; i++) {
            DetailEntity *detail = [details.allObjects objectAtIndex:i];
            NSString *imageP = [[WardrobesData cachePath] stringByAppendingPathComponent:detail.imagePath];
            UIImage *image = [UIImage imageWithContentsOfFile:imageP];
            
            CollectionViewCell *cell = (id)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathWithIndex:i]];
            UIImageView *imageView = cell.imageView;
            KSPhotoItem *item = [KSPhotoItem itemWithSourceView:imageView image:image];
            [items addObject:item];
        }
 
        KSPhotoBrowser *browser = [KSPhotoBrowser browserWithPhotoItems:items selectedIndex:indexPath.item];
        [browser showFromViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
        
    }
}


- (void)takePhoto
{
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
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
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
        // You can get the photos by block, the same as by delegate.
        // 你可以通过block或者代理，来得到用户选择的照片.
        [rootVC presentViewController:imagePickerVc animated:YES completion:nil];
    }];
    [alertVc addAction:cancle];
    [alertVc addAction:camera];
    [alertVc addAction:picture];
    
    UIWindow *wind = [UIApplication sharedApplication].keyWindow;
    [alertVc.popoverPresentationController setPermittedArrowDirections:0];
    alertVc.popoverPresentationController.sourceView=self;
    alertVc.popoverPresentationController.sourceRect=CGRectMake(CGRectGetMidX(wind.bounds), CGRectGetMidY(wind.bounds),0,0);
    [rootVC presentViewController:alertVc animated:YES completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    NSArray *entities = [WardrobesData entities];
    WardrobesEntity *entity = [entities objectAtIndex:self.tag];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (UIImage *oimage  in photos) {
            UIImage *image = [oimage fixOrientation:oimage];
            NSData *data;
            if (UIImagePNGRepresentation(image) ==nil)
            {
                data = UIImageJPEGRepresentation(image,1.0);
            }
            else
            {
                data = UIImagePNGRepresentation(image);
            }
            NSString *imagePath = [HomeCollectionView createImageWithImageData:data];
            DetailEntity *detail = [DetailEntity MR_createEntityInContext:[entity managedObjectContext]];
            [detail setBrief:@""];
            detail.imagePath = [[imagePath componentsSeparatedByString:@"Caches/"] lastObject];
            [entity addDetailObject:detail];
            [entity.managedObjectContext MR_saveToPersistentStoreAndWait];

        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self reloadData];
        });
        //关闭相册界面
        [picker dismissViewControllerAnimated:YES completion:nil];
    });

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
        image = [image fixOrientation:image];
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
        NSString *imagePath = [HomeCollectionView createImageWithImageData:data];
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

+ (NSString *)createImageWithImageData:(NSData *)data
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
    NSString *namestr = [NSString stringWithFormat:@"%ld%d%d",time(NULL),arc4random()%99999,arc4random()%99999];
    NSString *name = [self md5:namestr];
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
