//
//  HBExcelColumnHeader.m
//  iOSDemos
//
//  Created by zhoubo on 2017/4/14.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

#import "HBExcelColumnHeader.h"

@interface HBExcelColumnHeader ()

@property (nonatomic, strong) UIView *rightSeparator;

@property (nonatomic, strong) NSArray *headerDatas;

- (void)updateViewWithHeaderData:(id)data;

@end

@implementation HBExcelColumnHeader

- (void)setColumn:(NSInteger)column headerDatas:(NSArray *)headerDatas {
    _column = column;
    _headerDatas = headerDatas;
    [self updateViewWithHeaderData:_headerDatas[_column]];
}

- (void)updateView {
    [self updateViewWithHeaderData:_headerDatas[_column]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _column = -1;
        _rightSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.5, 40)];
        [self addSubview:_rightSeparator];
        _rightSeparator.backgroundColor = [UIColor hb_colorFromHexString:@"#E1E1E1"];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect rect = self.bounds;
    rect.origin.x = rect.size.width;
    rect.size.width = 0.5;
    _rightSeparator.frame = rect;
}

- (void)updateViewWithHeaderData:(id)data {
    
}

@end

@implementation HBExcelColumnLabelHeader

- (instancetype)init {
    self = [super init];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.textAlignment = NSTextAlignmentLeft;
        _label.font = [UIFont systemFontOfSize:15];
        _label.textColor = [UIColor hb_colorFromHexString:@"#9DA1C4"];
        [self addSubview:_label];
    }
    return self;
}

- (void)updateViewWithHeaderData:(id)data {
    if ([data isKindOfClass:[NSDictionary class]]) {
        NSInteger order = [data[@"order__"] integerValue];
        _label.text = [NSString stringWithFormat:@"%@%@", data[@"name"], @[@"",@" <",@" >"][order]];
        _label.textColor = [UIColor hb_colorFromHexString:order == HBExcelColumnOrderNone ? @"#9DA1C4":@"#42B76A"];
    } else {
        _label.text = @"";
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _label.frame = CGRectMake(15, 0, self.bounds.size.width-16, self.bounds.size.height);
}

@end
