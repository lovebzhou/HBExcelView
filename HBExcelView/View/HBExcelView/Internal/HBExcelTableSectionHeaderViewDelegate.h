//
//  HBExcelTableSectionHeaderViewDelegate.h
//  iOSDemos
//
//  Created by zhoubo on 2017/4/19.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

#ifndef HBExcelTableSectionHeaderViewDelegate_h
#define HBExcelTableSectionHeaderViewDelegate_h

@class HBExcelColumnHeader, HBExcelTableSectionHeaderView, HBExcelView;

@protocol HBExcelTableSectionHeaderViewDelegate <NSObject>

- (void)tableViewHeader:(HBExcelTableSectionHeaderView *)tableHeader columnWidthBeginChange:(HBExcelColumnHeader *)columnHeader;

- (void)tableViewHeader:(HBExcelTableSectionHeaderView *)tableHeader columnWidthEndChange:(HBExcelColumnHeader *)columnHeader;

- (void)tableViewHeader:(HBExcelTableSectionHeaderView *)tableHeader columnWidthDidChange:(HBExcelColumnHeader *)columnHeader newWidth:(CGFloat)newWidth;

- (void)tableViewHeader:(HBExcelTableSectionHeaderView *)tableHeader didSelectColumnHeader:(HBExcelColumnHeader *)columnHeader section:(NSInteger)section;

@end

#endif /* HBExcelTableSectionHeaderViewDelegate_h */
