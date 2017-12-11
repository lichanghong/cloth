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
    NSMutableArray *wardrobes = [WardrobesData wardrobeData].wardrobes;
    WardrobesItem *item = wardrobes[section];
    return item.wardrobesPaths.count==0?1:item.wardrobesPaths.count;
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
    NSMutableArray *wardrobes = [WardrobesData wardrobeData].wardrobes;
    WardrobesItem *item = wardrobes[collectionView.tag];
    if (indexPath.item == item.wardrobesPaths.count) {
        NSLog(@"%@ add.....",item.title);
    }
    else{
        NSLog(@"show.....%d   %d",indexPath.item,item.wardrobesPaths.count);
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
