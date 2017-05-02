//
//  UIColor+Demo.m
//  iOSDemos
//
//  Created by zhoubo on 15/12/18.
//  Copyright © 2015年 zhoubo. All rights reserved.
//

#import "UIColor+Demo.h"

@implementation UIColor (Demo)

+ (UIColor *)colorFromRGB:(NSInteger)rgb {
    return [UIColor colorWithRed:((float)((rgb & 0xFF0000) >> 16))/255.0
                           green:((float)((rgb & 0x00FF00) >>  8))/255.0
                            blue:((float)((rgb & 0x0000FF) >>  0))/255.0
                           alpha:1.0];
}

+ (UIColor *)hb_colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
