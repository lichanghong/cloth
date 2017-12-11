//
//  ViewController.m
//  衣柜
//
//  Created by lichanghong on 10/24/17.
//  Copyright © 2017 lichanghong. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewCell.h"
#import <CHBaseUtil.h>
#import <Alert.h>
#import<CommonCrypto/CommonDigest.h>
#import <MagicalRecord/MagicalRecord.h>

@interface ViewController ()<UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;



@end

@implementation ViewController
{
    Alert *alert ;
}

- (IBAction)addSection:(id)sender {

}


- (void)viewDidLoad {
    [super viewDidLoad];
 
}




// 选择图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        NSData *data;
        if (UIImagePNGRepresentation(image) ==nil)
        {
            data = UIImageJPEGRepresentation(image,1.0);
        }
        else
        {
            data = UIImagePNGRepresentation(image);
        }
        
        //图片保存的路径
        //这里将图片放在沙盒的documents文件夹中
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
        name = [NSString stringWithFormat:@"/%@.png",name];
        [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:name] contents:data attributes:nil];

        //关闭相册界面
        [picker dismissViewControllerAnimated:YES completion:nil];
        //加在视图中
 
    }
}
// 取消选取图片
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
