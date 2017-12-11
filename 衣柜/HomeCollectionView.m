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


@interface HomeCollectionView()
@property (nonatomic,strong)WardrobesItem *takePhotoItem;
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
    return 2;
//    NSMutableArray *wardrobes = [WardrobesData wardrobeData].wardrobes;
//    WardrobesItem *item = wardrobes[section];
//    return item.wardrobesPaths.count==0?1:item.wardrobesPaths.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *collVC = [collectionView dequeueReusableCellWithReuseIdentifier:[CollectionViewCell identifier] forIndexPath:indexPath];
    if (collVC) {
        collVC.backgroundColor = RandomColor;
    }
    return collVC;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    NSMutableArray *wardrobes = [WardrobesData wardrobeData].wardrobes;
//    WardrobesItem *item = wardrobes[collectionView.tag];
//    if (indexPath.item == item.wardrobesPaths.count) {
//        NSLog(@"%@ add.....",item.title);
//        self.takePhotoItem = item;
//        [self takePhoto];
//    }
//    else{
//        NSLog(@"show.....%d   %d",indexPath.item,item.wardrobesPaths.count);
//    }
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
    
        WardrobeItemDetail *detail = [WardrobeItemDetail createDetailWithInfo:info ImageData:data];
//        NSMutableArray *wardrobes = [WardrobesData wardrobeData].wardrobes;
//        WardrobesItem *item = wardrobes[self.tag];
//        [item.wardrobesPaths addObject:detail];
//        [self reloadData];
        //关闭相册界面
        [picker dismissViewControllerAnimated:YES completion:nil];
        
    }
}

- (NSString *) md5:(NSString *) input {
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
