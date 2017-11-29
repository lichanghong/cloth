//
//  CollectionHeader.m
//  衣柜
//
//  Created by lichanghong on 10/24/17.
//  Copyright © 2017 lichanghong. All rights reserved.
//

#import "CollectionHeader.h"
#import <CHBaseUtil.h>

@implementation CollectionHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.title.frame = CGRectMake(20, 5, KScreenWidth, frame.size.height);
        [self addSubview:self.title];
    }
    return self;
}

- (UILabel *)title
{
    if (_title) {
        return _title;
    }
    _title = [[UILabel alloc]init];
    _title.backgroundColor = [UIColor clearColor];
    _title.text = @"title";
    _title.textColor = [UIColor whiteColor];
    return _title;
}
+ (NSString *)identifier{
    return @"CollectionHeaderidentifier";
}
@end
