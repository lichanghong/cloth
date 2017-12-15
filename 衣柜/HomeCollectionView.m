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
#import "HomeAddAlert.h"


@interface HomeCollectionView()<TZImagePickerControllerDelegate>
@property (nonatomic,strong)WardrobesEntity *takePhotoItem;
@end

@implementation HomeCollectionView
{
    UILongPressGestureRecognizer *_longPress;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(lonePressMoving:)];
        [self addGestureRecognizer:_longPress];
    }
    return self;
}
- (void)lonePressMoving:(UILongPressGestureRecognizer *)longPress
{
    __weak typeof(self) ws = self;
    switch (longPress.state) {
        case UIGestureRecognizerStatePossible: {
            
            break;
        }
        case UIGestureRecognizerStateBegan: {
            {
                UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
                NSIndexPath *selectIndexPath = [self indexPathForItemAtPoint:[_longPress locationInView:self]];
                // 找到当前的cell
//                CollectionViewCell *cell = (CollectionViewCell *)[self cellForItemAtIndexPath:selectIndexPath];
                NSArray *entities = [WardrobesData entities];
                WardrobesEntity *entity = [entities objectAtIndex:self.tag];
                NSArray *details = [self detailsOfEntity:entity];
                DetailEntity *detail = details[selectIndexPath.item];
                [HomeAddAlert alertToDeleteInVC:rootVC success:^{
                    NSLog(@"begin............");
                    if (entity.detail.count==0) {
                        NSLog(@"没了");
                        return;
                    }
                    //detail删除了，他后面的detail.index-1
                    for (int i=(int)detail.index; i<details.count; i++) {
                        DetailEntity *d = details[i];
                        d.index-=1;
                    }
                    //删除图片文件及对象数据
                    NSString *imageP = [[WardrobesData cachePath] stringByAppendingPathComponent:detail.imagePath];
                    [[NSFileManager defaultManager] removeItemAtPath:imageP error:nil];
                    
                    [entity removeDetailObject:detail];
                    [entity.managedObjectContext MR_saveToPersistentStoreAndWait];
                    
                    [ws reloadData];
                }];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            
            break;
        }
        case UIGestureRecognizerStateEnded: {
            
            break;
        }
        case UIGestureRecognizerStateCancelled: {
            
            break;
        }
        case UIGestureRecognizerStateFailed: {
            
            break;
        }
    }
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *entities = [WardrobesData entities];
    if (entities.count<=collectionView.tag) {
        return 1;
    }
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
    collVC.imageView.image = nil;
    NSArray *entities = [WardrobesData entities];
    WardrobesEntity *entity = [entities objectAtIndex:collectionView.tag];

    if (entity.detail.count<=indexPath.item) {
        collVC.imageView.image = [UIImage imageNamed:@"add"];
    }
    else {
        if (entity.detail && entity.detail.count > indexPath.row) {
            DetailEntity *detail = [self detailsOfEntity:entity][indexPath.row];
            if (collVC) {
                NSString *imageP = [[WardrobesData cachePath] stringByAppendingPathComponent:detail.imagePath];
                UIImage *image = [UIImage imageWithContentsOfFile:imageP];
                collVC.imageView.image = image;
            }
        }
    }
    return collVC;
}


- (NSArray *)detailsOfEntity:(WardrobesEntity *)entity
{
    NSArray *sorted = [entity.detail.allObjects sortedArrayUsingComparator:^NSComparisonResult(DetailEntity* obj1, DetailEntity* obj2) {
        return obj1.index<obj2.index?NSOrderedAscending:NSOrderedDescending;
    }];
    return sorted;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *entities = [WardrobesData entities];
    if (entities.count<collectionView.tag) {
        return;
    }
    WardrobesEntity *entity = [entities objectAtIndex:collectionView.tag];
    NSArray *details = [self detailsOfEntity:entity];
    NSUInteger count = details.count;
    if (indexPath.item == count) {
        self.takePhotoItem = entity;
        [self takePhoto];
    }
    else{
        NSMutableArray *items = @[].mutableCopy;
        for (int i=0; i<details.count; i++) {
            DetailEntity *detail = [details objectAtIndex:i];
            NSString *imageP = [[WardrobesData cachePath] stringByAppendingPathComponent:detail.imagePath];
            UIImage *image = [UIImage imageWithContentsOfFile:imageP];
            
            CollectionViewCell *cell = (id)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathWithIndex:i]];
            UIImageView *imageView = cell.imageView;
            [imageView setImage:[UIImage new]];
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
            NSData *data = UIImagePNGRepresentation(image);
            if (UIImageJPEGRepresentation(image,0.5) ==nil)
            {
                data = UIImagePNGRepresentation(image);
            }
            
            NSString *imagePath = [HomeCollectionView createImageWithImageData:data];
            DetailEntity *detail = [DetailEntity MR_createEntityInContext:[entity managedObjectContext]];
            detail.imagePath = [[imagePath componentsSeparatedByString:@"Caches/"] lastObject];
            detail.index = (int)entity.detail.count;
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

        NSData *data = UIImagePNGRepresentation(image);
        if (UIImageJPEGRepresentation(image,0.5) ==nil)
        {
            data = UIImagePNGRepresentation(image);
        }


        NSArray *entities = [WardrobesData entities];
        WardrobesEntity *entity = [entities objectAtIndex:self.tag];
        NSString *imagePath = [HomeCollectionView createImageWithImageData:data];
        __weak HomeCollectionView *weakself = self;

        DetailEntity *detail = [DetailEntity MR_createEntityInContext:[entity managedObjectContext]];
        detail.index = (int)entity.detail.count;
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
