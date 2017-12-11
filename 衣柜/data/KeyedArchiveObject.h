//
//  KeyedArchiveObject.h
//  衣柜
//
//  Created by lichanghong on 12/11/17.
//  Copyright © 2017 lichanghong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import<CommonCrypto/CommonDigest.h>

@interface KeyedArchiveObject : NSObject<NSCoding>
+ (NSString *) md5:(NSString *) input ;
@end
