//
//  CollectionHeader.h
//  衣柜
//
//  Created by lichanghong on 10/24/17.
//  Copyright © 2017 lichanghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionHeader : UICollectionReusableView
@property (nonatomic,strong)UILabel *title;
+ (NSString *)identifier;


@end
