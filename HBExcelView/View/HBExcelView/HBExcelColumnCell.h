//
//  HBExcelColumnCell.h
//  iOSDemos
//
//  Created by zhoubo on 2017/4/14.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HBExcelColumnCell : UIView

@property (nonatomic, /*readonly,*/ strong, nullable) NSString *reuseIdentifier;

@property (nonatomic) NSInteger column;

- (void)setHeaderDatas:(NSArray *)headerDatas rowDatas:(NSArray *)rowDatas column:(NSInteger)column indexPath:(NSIndexPath *)indexPath;

@end

@interface HBExcelColumnNumberCell : HBExcelColumnCell

@property (nonatomic, strong) UILabel *label;

@end

@interface HBExcelColumnLabelCell : HBExcelColumnCell

@property (nonatomic, strong) UILabel *label;

@end

NS_ASSUME_NONNULL_END
