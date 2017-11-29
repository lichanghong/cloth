//
//  CollectionViewCell.m
//  衣柜
//
//  Created by lichanghong on 10/24/17.
//  Copyright © 2017 lichanghong. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        self.imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
    return self;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        _imageView.image = [UIImage imageNamed:@"add"];
    }
    return _imageView;
}
+ (NSString *)identifier
{
    return @"basecollectionviewcellIdentifier";
}
@end
