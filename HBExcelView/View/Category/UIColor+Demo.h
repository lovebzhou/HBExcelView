//
//  UIColor+Demo.h
//  iOSDemos
//
//  Created by zhoubo on 15/12/18.
//  Copyright © 2015年 zhoubo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Demo)

+ (UIColor *)colorFromRGB:(NSInteger)rgb;

+ (UIColor *)hb_colorFromHexString:(NSString *)hexString;

@end
