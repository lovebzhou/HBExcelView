//
//  HBExcelViewDataSource.h
//  iOSDemos
//
//  Created by zhoubo on 2017/4/18.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

#ifndef HBExcelViewDataSource_h
#define HBExcelViewDataSource_h

@class HBExcelView;

@protocol HBExcelViewDataSource <NSObject>

- (NSInteger)numberOfColumnsInExcelView:(HBExcelView *)excelView;

- (NSInteger)numberOfRowsInExcelView:(HBExcelView *)excelView;

- (CGFloat)excelView:(HBExcelView *)excelView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSArray *)excelView:(HBExcelView *)excelView datasOfRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *)excelView:(HBExcelView *)excelView columnCellIdentfierAtColumn:(NSInteger)column indexPath:(NSIndexPath *)indexPath headerDatas:(NSArray *)headerDatas rowDatas:(NSArray *)rowDatas;

- (NSString *)excelView:(HBExcelView *)excelView columnHeaderIdentfierAtColumn:(NSInteger)column section:(NSInteger)section headerDatas:(NSArray *)headerDatas;

- (BOOL)hasMoreRowsInExcelView:(HBExcelView *)excelView;

- (void)loadMoreRowsInExcelView:(HBExcelView *)excelView;

@optional

- (NSInteger)numberOfSectionsInExcelView:(HBExcelView *)excelView;

- (CGFloat)excelView:(HBExcelView *)excelView heightForHeaderInSection:(NSInteger)section;

- (NSString *)excelView:(HBExcelView *)excelView titleForHeaderInSection:(NSInteger)section columnIndex:(NSInteger)columnIndex;

- (NSArray *)excelView:(HBExcelView *)excelView datasOfHeaderAtSection:(NSInteger)section;

@end

#endif /* HBExcelViewDataSource_h */
