//
//  HBExcelView.h
//  iOSDemos
//
//  Created by zhoubo on 2017/4/13.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HBExcelColumnCell.h"
#import "HBExcelColumnHeader.h"
#import "HBExcelViewDelegate.h"
#import "HBExcelViewDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface HBExcelView : UIView

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, weak) id<HBExcelViewDataSource> dataSource;
@property (nullable, nonatomic, weak) id<HBExcelViewDelegate> delegate;

@property (nonatomic) CGFloat minColumnWith; // default 70
@property (nonatomic) CGFloat rightPadding; // default 15

@property (nonatomic, readonly) NSInteger fixedColumnCount; // default 0
@property (nonatomic, readonly) CGFloat fixedColumnsWidth;
@property (nonatomic, readonly) CGFloat columnsWidth;
@property (nonatomic, strong, readonly) NSMutableArray<NSNumber *> *columnWidths;

- (void)setColumnWidths:(NSMutableArray<NSNumber *> *)columnWidths fixedColumnCount:(NSInteger)fixedColumnCount;

- (void)updateHeaderAtColumn:(NSInteger)column section:(NSInteger)section;

- (void)reloadData;

- (void)registerClass:(Class)columnCellClass forReusableColumnCellIdentifier:(NSString *)identifier;
- (void)registerClass:(Class)columnHeaderClass forReusableColumnHeaderIdentifier:(NSString *)identifier;

#pragma mark - Internal

- (NSArray *)datasOfRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)datasOfHeaderAtSection:(NSInteger)section;

- (NSString *)cellIdetifierAtColumn:(NSInteger)column indexPath:(NSIndexPath *)indexPath headerDatas:(NSArray *)headerDatas rowDatas:(NSArray *)rowDatas;
- (NSString *)headerIdetifierAtColumn:(NSInteger)column section:(NSInteger)section headerDatas:(NSArray *)headerDatas;

- (void)enqueueReusableColumnCell:(HBExcelColumnCell *)cell;
- (HBExcelColumnCell *)dequeueReusableColumnCellWithIdentifier:(NSString *)identifier indexPath:(NSIndexPath *)indexPath;
- (HBExcelColumnCell *)dequeueReusableCellWithColumn:(NSInteger)column indexPath:(NSIndexPath *)indexPath headerDatas:(NSArray *)headerDatas rowDatas:(NSArray *)rowDatas;

- (void)enqueueReusableColumnHeader:(HBExcelColumnHeader *)header;
- (HBExcelColumnHeader *)dequeueReusableColumnHeaderWithIdentifier:(NSString *)identifier section:(NSInteger)section;
- (HBExcelColumnHeader *)dequeueReusableHeaderWithColumn:(NSInteger)column section:(NSInteger)section headerDatas:(NSArray *)headerDatas;

@property (nonatomic, strong, nullable) HBExcelColumnHeader *draggingColumnHeader;

@end

NS_ASSUME_NONNULL_END
