//
//  HomeTableViewCell.m
//  衣柜
//
//  Created by lichanghong on 12/5/17.
//  Copyright © 2017 lichanghong. All rights reserved.
//

#import "HomeTableViewCell.h"
#import "HomeCollectionView.h"
#import <CHBaseUtil.h>

@interface HomeTableViewCell()

@property (strong, nonatomic) IBOutlet HomeCollectionView *homeCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewW;

@end

@implementation HomeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    __weak typeof(self) weakself = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [weakself setNeedsUpdateConstraints];
        [weakself updateConstraintsIfNeeded];
    }];
    // Initialization code
}

- (void)updateConstraints
{
    [super updateConstraints];
    self.collectionViewW.constant = self.contentView.bounds.size.width;
}
 
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
