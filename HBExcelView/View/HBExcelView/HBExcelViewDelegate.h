//
//  HBExcelViewDelegate.h
//  iOSDemos
//
//  Created by zhoubo on 2017/4/18.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

#ifndef HBExcelViewDelegate_h
#define HBExcelViewDelegate_h

@class HBExcelView;

@protocol HBExcelViewDelegate <NSObject>

@optional

- (void)excelView:(HBExcelView *)excelView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)excelView:(HBExcelView *)excelView didSelectColumnHeader:(HBExcelColumnHeader *)columnHeader section:(NSInteger)section;

- (void)excelView:(HBExcelView *)excelView scrollDidChange:(UIScrollView *)scrollView;

- (void)excelView:(HBExcelView *)excelView widthDidChangeOfColumnHeader:(HBExcelColumnHeader *)columnHeader newWidth:(CGFloat)newWidth section:(NSInteger)section;

@end

#endif /* HBExcelViewDelegate_h */
