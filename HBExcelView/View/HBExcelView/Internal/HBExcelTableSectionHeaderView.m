//
//  HBExcelTableSectionHeaderView.h
//  iOSDemos
//
//  Created by zhoubo on 2017/4/14.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

#import "HBExcelTableSectionHeaderView.h"
#import "HBExcelView.h"

static void *kHBScrollViewContentOffset = &kHBScrollViewContentOffset;

@interface HBExcelTableSectionHeaderView ()

@property (nonatomic, strong) UIView *fixedView;

@property (nonatomic, strong) NSMutableArray<HBExcelColumnHeader *> *fixedColumnHeaders;
@property (nonatomic, strong) NSMutableArray<HBExcelColumnHeader *> *columnHeaders;
@property (nonatomic) NSInteger isFixedColumnsUpdated;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

@end

@implementation HBExcelTableSectionHeaderView

- (void)dealloc {
    [_scrollView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset))];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _fixedColumnHeaders = nil;
    _columnHeaders = nil;
    _isFixedColumnsUpdated = NO;
    
    [_scrollView addObserver:self
                  forKeyPath:NSStringFromSelector(@selector(contentOffset))
                     options:NSKeyValueObservingOptionNew
                     context:kHBScrollViewContentOffset];
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
    [_scrollView addGestureRecognizer:_tapGestureRecognizer];
    
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestureRecognizer:)];
    _longPressGestureRecognizer.minimumPressDuration = 0.2;
    [_scrollView addGestureRecognizer:_longPressGestureRecognizer];
}

- (UIView *)fixedView {
    if (_fixedView == nil) {
        _fixedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _excelView.fixedColumnsWidth, self.frame.size.height)];
        [_scrollView addSubview:_fixedView];
        _fixedView.backgroundColor = self.scrollView.backgroundColor;
    }
    return _fixedView;
}

#pragma mark -

- (HBExcelColumnHeader *)headerAtColumn:(NSInteger)column inHeaders:(NSArray *)headers {
    for (HBExcelColumnHeader *header in headers) {
        if (header.column == column) return header;
    }
    return nil;
}

- (void)updateVisibleHeadersFromColumn:(NSInteger)column {
    NSArray *datas = [_excelView datasOfHeaderAtSection:_section];
    NSArray *columnWidths = _excelView.columnWidths;
    
    NSInteger state = 0;
    CGFloat x0 = _scrollView.contentOffset.x;
    CGFloat x1 = x0 + _scrollView.frame.size.width;
    CGFloat h = _scrollView.frame.size.height;
    CGFloat x = _excelView.fixedColumnsWidth;
    for (NSInteger i = _excelView.fixedColumnCount; i < column; ++i) {
        x += [columnWidths[i] floatValue];
    }
    for (NSInteger i = column; i < datas.count; ++i) {
        CGFloat w = [columnWidths[i] floatValue];
        
        if ((x < x1) &&((x+w) > x0)) {
            state = 1;
            HBExcelColumnHeader *header = [self headerAtColumn:i inHeaders:_columnHeaders];
            if (header == nil) {
                header = [_excelView dequeueReusableHeaderWithColumn:i section:_section headerDatas:datas];
                [_scrollView addSubview:header];
                [_columnHeaders addObject:header];
            }
            
            if (header) {
                header.frame = CGRectMake(x, 0, w, h);
                [header setColumn:i headerDatas:datas];
            }
        } else {
            if (state == 1) {
                HBExcelColumnHeader *lastHeader = _columnHeaders.lastObject;
                while (lastHeader.column >= i) {
                    [lastHeader removeFromSuperview];
                    [_excelView enqueueReusableColumnHeader:lastHeader];
                    [_columnHeaders removeObject:lastHeader];
                    lastHeader = _columnHeaders.lastObject;
                }
                break;
            }
        }
        
        x += w;
    }
}

- (HBExcelColumnHeader *)dequeueHeaderWithIdentifier:(NSString *)identifier inHeaders:(NSMutableArray *)headers {
    for (HBExcelColumnHeader *header in headers) {
        if ([header.reuseIdentifier isEqualToString:identifier]) {
            [headers removeObject:header];
            return header;
        }
    }
    return nil;
}

- (void)updateFixedColumnHeaders {
    if (_isFixedColumnsUpdated) return;
    _isFixedColumnsUpdated = YES;
    
    if (_fixedColumnHeaders.count != _excelView.fixedColumnCount) {
        [_fixedColumnHeaders enumerateObjectsUsingBlock:^(HBExcelColumnHeader * _Nonnull header, NSUInteger idx, BOOL * _Nonnull stop) {
            [header removeFromSuperview];
        }];
        _fixedColumnHeaders = nil;
    }
    
    if (_excelView.fixedColumnCount == 0) return;

    NSArray *datas = [_excelView datasOfHeaderAtSection:_section];
    
    if (_fixedColumnHeaders) {
        [_fixedColumnHeaders enumerateObjectsUsingBlock:^(HBExcelColumnHeader * _Nonnull header, NSUInteger i, BOOL * _Nonnull stop) {
            [header setColumn:i headerDatas:datas];
        }];
    } else {
        _fixedColumnHeaders = [NSMutableArray arrayWithCapacity:_excelView.fixedColumnCount];
        CGRect frame = self.frame;
        frame.origin.x = _scrollView.contentOffset.x > 0 ? _scrollView.contentOffset.x : 0;
        for (NSInteger i = 0; i < _excelView.fixedColumnCount; ++i) {
            frame.size.width = [_excelView.columnWidths[i] floatValue];

            HBExcelColumnHeader *header = [_excelView dequeueReusableHeaderWithColumn:i section:_section headerDatas:datas];
            [self.fixedView addSubview:header];
            header.frame = frame;
            [_fixedColumnHeaders addObject:header];
            [header setColumn:i headerDatas:datas];

            frame.origin.x += frame.size.width;
        }
    }
}

- (void)updateVisibleHeaders {
    [self updateFixedColumnHeaders];
    
    NSArray *datas = [_excelView datasOfHeaderAtSection:_section];
    
    CGRect rect = _scrollView.frame;
    rect.origin.x = _scrollView.contentOffset.x;
    
    NSInteger state = 0;
    NSMutableArray *reusableHeaders = _columnHeaders;
    _columnHeaders = [NSMutableArray arrayWithCapacity:5];
    CGRect frame = CGRectMake(_excelView.fixedColumnsWidth, 0, 0, rect.size.height);
    for (NSInteger i = _excelView.fixedColumnCount; i < datas.count; ++i) {
        frame.size.width = [_excelView.columnWidths[i] floatValue];
        
        if (CGRectIntersectsRect(rect, frame)) {
            state = 1;
            NSString *identifier = [_excelView headerIdetifierAtColumn:i section:_section headerDatas:datas];
            HBExcelColumnHeader *header = [self dequeueHeaderWithIdentifier:identifier inHeaders:reusableHeaders];
            if (header == nil) {
                header = [_excelView dequeueReusableHeaderWithColumn:i section:_section headerDatas:datas];
                [_scrollView addSubview:header];
            }
            if (header) {
                [_columnHeaders addObject:header];
                header.frame = frame;
                [header setColumn:i headerDatas:datas];
            }
        } else {
            if (state == 1) {
                break;
            }
        }
        
        frame.origin.x += frame.size.width;
    }
    
    for (HBExcelColumnHeader *header in reusableHeaders) {
        [_excelView enqueueReusableColumnHeader:header];
        [header removeFromSuperview];
    }
    
    if (_fixedView) {
        [_scrollView bringSubviewToFront:_fixedView];
    }
}

#pragma mark -

- (void)prepareForReuse {
    [super prepareForReuse];
    _isFixedColumnsUpdated = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_fixedView) {
        [_scrollView bringSubviewToFront:_fixedView];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == kHBScrollViewContentOffset) {
        CGPoint newOffset = [change[@"new"] CGPointValue];
        if (_fixedView) {
            CGRect frame = _fixedView.frame;
            if (newOffset.x > 0) {
                frame.origin.x = newOffset.x;
            } else {
                frame.origin.x = 0;
            }
            _fixedView.frame = frame;
        }
        
        if (_excelView.draggingColumnHeader == nil) {
            [self updateVisibleHeaders];
        }
    }
}

#pragma mark - UIGestureRecognizer

- (HBExcelColumnHeader *)headerAtColumn:(NSInteger)column {
    for (HBExcelColumnHeader *header in _columnHeaders) {
        if (header.column == column) {
            return header;
        }
    }
    return nil;
}

- (HBExcelColumnHeader *)columnHeaderAtPoint:(CGPoint)point { // TODO:maybe need not
    if (point.x < CGRectGetMaxX(_fixedView.frame)) return nil;
    
    HBExcelColumnHeader *columnHeader = nil;
    CGFloat x = _excelView.fixedColumnsWidth;
    for (NSInteger i = _excelView.fixedColumnCount; i < _excelView.columnWidths.count; ++i) {
        CGFloat w = [_excelView.columnWidths[i] floatValue];
        if ((point.x > x) && (point.x < (x + w))) {
            columnHeader = [self headerAtColumn:i];
        }
        x += w;
    }

    if (columnHeader == nil) {
        CGFloat xz =  point.x - (_scrollView.contentSize.width - _excelView.rightPadding);
        if (xz < 25) { // last header
            columnHeader = _columnHeaders.lastObject;
        }
    }
    
    return columnHeader;
}

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.scrollView];
    HBExcelColumnHeader *columnHeader = [self columnHeaderAtPoint:point];
    
    if (columnHeader && [_headerDelegate respondsToSelector:@selector(tableViewHeader:didSelectColumnHeader:section:)]) {
        [_headerDelegate tableViewHeader:self didSelectColumnHeader:columnHeader section:_section];
    }
}

- (void)handleLongPressGestureRecognizer:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.scrollView];
    if (_excelView.draggingColumnHeader) {
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            if ([_headerDelegate respondsToSelector:@selector(tableViewHeader:columnWidthEndChange:)]) {
                [_headerDelegate tableViewHeader:self columnWidthEndChange:_excelView.draggingColumnHeader];
            }
            _excelView.draggingColumnHeader = nil;
        } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
            if ([_headerDelegate respondsToSelector:@selector(tableViewHeader:columnWidthDidChange:newWidth:)]) {
                [_headerDelegate tableViewHeader:self columnWidthDidChange:_excelView.draggingColumnHeader newWidth:point.x - _excelView.draggingColumnHeader.frame.origin.x];
            }
        } else {
            if ([_headerDelegate respondsToSelector:@selector(tableViewHeader:columnWidthEndChange:)]) {
                [_headerDelegate tableViewHeader:self columnWidthEndChange:_excelView.draggingColumnHeader];
            }
            _excelView.draggingColumnHeader = nil;
        }
    } else {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            HBExcelColumnHeader *headerView = [self columnHeaderAtPoint:point];
            const CGFloat span = 25;
            CGFloat x0 = point.x - headerView.frame.origin.x;
            if ((x0 > span) && (x0 < (headerView.frame.size.width - span))) {
                return;
            }
            
            if (x0 < span) {
                if (headerView.column == _excelView.fixedColumnCount) {
                    return;
                }
                headerView = [self headerAtColumn:headerView.column -1];
            }

            _excelView.draggingColumnHeader = headerView;
            if ([_headerDelegate respondsToSelector:@selector(tableViewHeader:columnWidthBeginChange:)]) {
                [_headerDelegate tableViewHeader:self columnWidthBeginChange:_excelView.draggingColumnHeader];
            }
        }
    }
}

@end
