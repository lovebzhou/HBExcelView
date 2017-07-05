//
//  HBExcelColumnCell.m
//  iOSDemos
//
//  Created by zhoubo on 2017/4/14.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

#import "HBExcelColumnCell.h"
#import "HBLineView.h"

@interface HBExcelColumnCell ()

@property (nonatomic, strong) HBLineView *rightSeparator;

@end

@implementation HBExcelColumnCell

- (instancetype)init {
    self = [super init];
    if (self) {
        _rightSeparator = [[HBLineView alloc] initWithFrame:CGRectMake(0, 0, 0.5, 40)];
        [self addSubview:_rightSeparator];
        _rightSeparator.lineColor = [UIColor hb_colorFromHexString:HBSeparatorColor];
    }
    return self;
}

- (void)setHeaderDatas:(NSArray *)headerDatas rowDatas:(NSArray *)rowDatas column:(NSInteger)column indexPath:(nonnull NSIndexPath *)indexPath {
    _column = column;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect rect = self.frame;
    rect.origin.x = rect.size.width;
    rect.size.width = 0.5;
    _rightSeparator.frame = rect;
}

@end

@implementation HBExcelColumnNumberCell

- (instancetype)init {
    self = [super init];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [UIFont systemFontOfSize:15];
        _label.textColor =  [UIColor hb_colorFromHexString:@"#9DA1C4"];
        [self addSubview:_label];
    }
    return self;
}

- (void)setHeaderDatas:(NSArray *)headerDatas rowDatas:(NSArray *)rowDatas column:(NSInteger)column indexPath:(NSIndexPath *)indexPath {
    [super setHeaderDatas:headerDatas rowDatas:rowDatas column:column indexPath:indexPath];
    _label.text = [NSString stringWithFormat:@"%ld", indexPath.row+1];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _label.frame = self.bounds;
}

@end

@implementation HBExcelColumnLabelCell

- (instancetype)init {
    self = [super init];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        [self addSubview:_label];
        _label.clipsToBounds = YES;
        _label.textAlignment = NSTextAlignmentLeft;
        _label.font = [UIFont systemFontOfSize:15];
        _label.textColor = [UIColor hb_colorFromHexString:@"#4B4B4B"];
    }
    return self;
}

- (void)setHeaderDatas:(NSArray *)headerDatas rowDatas:(NSArray *)rowDatas column:(NSInteger)column indexPath:(NSIndexPath *)indexPath {
    [super setHeaderDatas:headerDatas rowDatas:rowDatas column:column indexPath:indexPath];
    NSDictionary *config = headerDatas[column];
    NSDictionary *data = rowDatas[column];
    if (data) {
        _label.text = data[@"value"];
    } else {
        _label.text = @"";
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _label.frame = CGRectMake(15, 0, self.bounds.size.width-16, self.bounds.size.height);
}

@end
