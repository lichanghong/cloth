//
//  UIImage.h
//  衣柜
//
//  Created by lichanghong on 12/12/17.
//  Copyright © 2017 lichanghong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (Orientation)

- (UIImage *)fixOrientation:(UIImage *)aImage;

@end
