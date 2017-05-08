//
//  HBExcelTableViewCell.m
//  iOSDemos
//
//  Created by zhoubo on 2017/4/13.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

#import "HBExcelTableViewCell.h"
#import "HBExcelView.h"

static void *kHBScrollViewContentOffset = &kHBScrollViewContentOffset;

/**
 * to resolve tableview not receive touching while a cell with a scrollview inside.
 * still has problem for long press, to be determine.
 */
@interface HBExelTableViewCellScrollView : UIScrollView

@end

@implementation HBExelTableViewCellScrollView

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.dragging)
        [self.superview touchesCancelled: touches withEvent:event];
    else
        [super touchesCancelled: touches withEvent: event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.dragging)
        [self.superview touchesMoved: touches withEvent:event];
    else
        [super touchesMoved: touches withEvent: event];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.dragging)
        [self.superview touchesBegan: touches withEvent:event];
    else
        [super touchesBegan: touches withEvent: event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.dragging)
        [self.superview touchesEnded: touches withEvent:event];
    else
        [super touchesEnded: touches withEvent: event];
}

@end

@interface HBExcelTableViewCell ()

@property (nonatomic, strong) UIView *fixedView;

@property (nonatomic, strong) NSMutableArray<HBExcelColumnCell *> *fixedColumnCells;
@property (nonatomic, strong) NSMutableArray<HBExcelColumnCell *> *columnCells;
@property (nonatomic) NSInteger isFixedColumnsUpdated;

@end

@implementation HBExcelTableViewCell

- (void)dealloc {
    [_scrollView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset))];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _fixedColumnCells = nil;
    _columnCells = nil;
    _isFixedColumnsUpdated = NO;

    [_scrollView addObserver:self
                  forKeyPath:NSStringFromSelector(@selector(contentOffset))
                     options:NSKeyValueObservingOptionNew
                     context:kHBScrollViewContentOffset];
}

- (UIView *)fixedView {
    if (_fixedView == nil) {
        _fixedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.excelView.fixedColumnsWidth, self.frame.size.height)];
        [_scrollView addSubview:_fixedView];
    }
    return _fixedView;
}

#pragma mark -

- (HBExcelColumnCell *)cellAtColumn:(NSInteger)column inCells:(NSArray *)cells {
    for (HBExcelColumnCell *cell in cells) {
        if (cell.column == column) return cell;
    }
    return nil;
}

- (void)updateVisibleCellsFromColumn:(NSInteger)column {
    NSArray *headerDatas = [_excelView datasOfHeaderAtSection:_indexPath.section];
    NSArray *rowDatas = [_excelView datasOfRowAtIndexPath:_indexPath];
    NSArray *columnWidths = _excelView.columnWidths;
    
    NSInteger state = 0;
    CGFloat x0 = _scrollView.contentOffset.x;
    CGFloat x1 = x0 + _scrollView.frame.size.width;
    CGFloat h = _scrollView.frame.size.height;
    CGFloat x = _excelView.fixedColumnsWidth;
    for (NSInteger i = _excelView.fixedColumnCount; i < column; ++i) {
        x += [columnWidths[i] floatValue];
    }
    for (NSInteger i = column; i < headerDatas.count; ++i) {
        CGFloat w = [columnWidths[i] floatValue];
        if ((x < x1) &&((x+w) > x0)) {
            state = 1;
            HBExcelColumnCell *cell = [self cellAtColumn:i inCells:_columnCells];
            if (cell == nil) {
                cell = [self.excelView dequeueReusableCellWithColumn:i indexPath:_indexPath headerDatas:headerDatas rowDatas:rowDatas];
                [_scrollView addSubview:cell];
                [_columnCells addObject:cell];
            }
            
            if (cell) {
                cell.frame = CGRectMake(x, 0, w, h);
                [cell setHeaderDatas:headerDatas rowDatas:rowDatas column:i indexPath:_indexPath];
            }
        } else {
            if (state == 1) {
                HBExcelColumnCell *lastCell = _columnCells.lastObject;
                while (lastCell.column >= i) {
                    [lastCell removeFromSuperview];
                    [_excelView enqueueReusableColumnCell:lastCell];
                    [_columnCells removeObject:lastCell];
                    lastCell = _columnCells.lastObject;
                }
                break;
            }
        }
        
        x += w;
    }
}

- (HBExcelColumnCell *)dequeueCellWithIdentifier:(NSString *)identifier inCells:(NSMutableArray *)cells {
    for (HBExcelColumnCell *cell in cells) {
        if ([cell.reuseIdentifier isEqualToString:identifier]) {
            [cells removeObject:cell];
            return cell;
        }
    }
    return nil;
}

- (void)updateFixedColumnCells {
    if (_isFixedColumnsUpdated) return;
    _isFixedColumnsUpdated = YES;
    
    if (_fixedColumnCells.count != _excelView.fixedColumnCount) {
        [_fixedColumnCells enumerateObjectsUsingBlock:^(HBExcelColumnCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
            [cell removeFromSuperview];
        }];
        _fixedColumnCells = nil;
    }
    
    if (_excelView.fixedColumnCount == 0) return;
    
    NSArray *headerDatas = [_excelView datasOfHeaderAtSection:_indexPath.section];
    NSArray *rowDatas = [_excelView datasOfRowAtIndexPath:_indexPath];
    
    if (_fixedColumnCells) {
        [_fixedColumnCells enumerateObjectsUsingBlock:^(HBExcelColumnCell * _Nonnull cell, NSUInteger i, BOOL * _Nonnull stop) {
            [cell setHeaderDatas:headerDatas rowDatas:rowDatas column:i indexPath:_indexPath];
        }];
    } else {
        _fixedColumnCells = [NSMutableArray arrayWithCapacity:_excelView.fixedColumnCount];
        CGRect frame = self.frame;
        frame.origin.x = _scrollView.contentOffset.x > 0 ? _scrollView.contentOffset.x : 0;
        for (NSInteger i = 0; i < _excelView.fixedColumnCount; ++i) {
            frame.size.width = [self.excelView.columnWidths[i] floatValue];
            HBExcelColumnCell *cell = [self.excelView dequeueReusableCellWithColumn:i indexPath:_indexPath headerDatas:headerDatas rowDatas:rowDatas];
            [self.fixedView addSubview:cell];
            cell.frame = frame;
            [_fixedColumnCells addObject:cell];
            [cell setHeaderDatas:headerDatas rowDatas:rowDatas column:i indexPath:_indexPath];

            frame.origin.x += frame.size.width;
        }
    }
}

- (void)updateVisibleCells {
    [self updateFixedColumnCells];
    
    NSArray *headerDatas = [_excelView datasOfHeaderAtSection:_indexPath.section];
    NSArray *rowDatas = [_excelView datasOfRowAtIndexPath:_indexPath];
    
    CGRect rect = _scrollView.frame;
    rect.origin.x = _scrollView.contentOffset.x;
    
    NSInteger state = 0;
    NSMutableArray *reusableCells = _columnCells;
    _columnCells = [NSMutableArray arrayWithCapacity:5];
    CGRect frame = CGRectMake(self.excelView.fixedColumnsWidth, 0, 0, rect.size.height);
    for (NSInteger i = _excelView.fixedColumnCount; i < headerDatas.count; ++i) {
        frame.size.width = [self.excelView.columnWidths[i] floatValue];
        
        if (CGRectIntersectsRect(rect, frame)) {
            state = 1;
            NSString *identifier = [self.excelView cellIdetifierAtColumn:i indexPath:_indexPath headerDatas:headerDatas rowDatas:rowDatas];
            HBExcelColumnCell *cell = [self dequeueCellWithIdentifier:identifier inCells:reusableCells];
            if (cell == nil) {
                cell = [self.excelView dequeueReusableCellWithColumn:i indexPath:_indexPath headerDatas:headerDatas rowDatas:rowDatas];
                [_scrollView addSubview:cell];
            }
            if (cell) {
                [_columnCells addObject:cell];
                cell.frame = frame;
                [cell setHeaderDatas:headerDatas rowDatas:rowDatas column:i indexPath:_indexPath];
            }
        } else {
            if (state == 1) {
                break;
            }
        }
        
        frame.origin.x += frame.size.width;
    }
    
    for (HBExcelColumnCell *cell in reusableCells) {
        [self.excelView enqueueReusableColumnCell:cell];
        [cell removeFromSuperview];
    }
    
    if (_fixedView) {
        [_scrollView bringSubviewToFront:_fixedView];
    }
}

#pragma mark -

- (void)prepareForReuse {
    [super prepareForReuse];
    _isFixedColumnsUpdated = NO;
    _indexPath = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_fixedView) {
        _fixedView.backgroundColor = self.contentView.backgroundColor;
        [_scrollView bringSubviewToFront:_fixedView];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == kHBScrollViewContentOffset) {
        if (_indexPath.row < [_excelView.dataSource numberOfRowsInExcelView:_excelView]) {
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
                [self updateVisibleCells];
            }
        }
    }
}

@end
