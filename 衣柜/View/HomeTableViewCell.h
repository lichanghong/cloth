//
//  HomeTableViewCell.h
//  衣柜
//
//  Created by lichanghong on 12/5/17.
//  Copyright © 2017 lichanghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeCollectionView.h"


@interface HomeTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet HomeCollectionView *homeCollectionView;

@end
