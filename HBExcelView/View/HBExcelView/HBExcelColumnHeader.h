//
//  HBExcelColumnHeader.h
//  iOSDemos
//
//  Created by zhoubo on 2017/4/14.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, HBExcelColumnOrderType) {
    HBExcelColumnOrderNone,
    HBExcelColumnOrderDesc,
    HBExcelColumnOrderAsc
};

@interface HBExcelColumnHeader : UIView

@property (nonatomic, /*readonly,*/ strong, nullable) NSString *reuseIdentifier;

@property (nonatomic) NSInteger column;

- (void)setColumn:(NSInteger)column headerDatas:(NSArray *)headerDatas;

- (void)updateView;

@end

@interface HBExcelColumnLabelHeader : HBExcelColumnHeader

@property (nonatomic, strong) UILabel *label;

@end

NS_ASSUME_NONNULL_END
