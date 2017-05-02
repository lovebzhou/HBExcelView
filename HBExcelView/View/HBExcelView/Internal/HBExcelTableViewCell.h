//
//  HBExcelTableViewCell.h
//  iOSDemos
//
//  Created by zhoubo on 2017/4/13.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HBExcelColumnCell, HBExcelView;

@interface HBExcelTableViewCell : UITableViewCell

@property (weak, nonatomic) HBExcelView *excelView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) NSIndexPath *indexPath;

- (void)updateVisibleCells;
- (void)updateVisibleCellsFromColumn:(NSInteger)column;

@end

NS_ASSUME_NONNULL_END
