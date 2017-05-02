//
//  HBExcelTableSectionHeaderView.h
//  iOSDemos
//
//  Created by zhoubo on 2017/4/14.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBExcelTableSectionHeaderViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface HBExcelTableSectionHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) HBExcelView *excelView;
@property (weak, nonatomic) id<HBExcelTableSectionHeaderViewDelegate> headerDelegate;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic) NSInteger section;

- (HBExcelColumnHeader *)headerAtColumn:(NSInteger)column;

- (void)updateVisibleHeaders;
- (void)updateVisibleHeadersFromColumn:(NSInteger)column;

@end

NS_ASSUME_NONNULL_END
