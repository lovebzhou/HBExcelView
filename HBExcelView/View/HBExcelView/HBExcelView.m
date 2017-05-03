//
//  HBExcelView.m
//  iOSDemos
//
//  Created by zhoubo on 2017/4/13.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

#import "HBExcelView.h"
#import "HBExcelTableViewCell.h"
#import "HBExcelTableSectionHeaderView.h"
#import "HBExcelColumnHeader.h"
#import "HBExcelColumnCell.h"

#import "UITableView+LoadingMore.h"

@interface HBExcelView () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, HBExcelTableSectionHeaderViewDelegate>

@property (nonatomic, strong) UIView *columnWidthChangeIndicator;

@property (nonatomic, strong) UIScrollView *blankFooterScrollView;
@property (nonatomic) CGFloat nonBlankContentHeight;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) NSMutableDictionary *reusableColumnCellClasses;
@property (nonatomic, strong) NSMutableDictionary *reusableColumnHeaderClasses;

@property (nonatomic, strong) NSMutableDictionary *reusableColumnCells;
@property (nonatomic, strong) NSMutableDictionary *reusableColumnHeaders;

@property (nonatomic) CGPoint contentOffset;

@property (nonatomic) NSInteger fixedColumnCount;
@property (nonatomic) CGFloat fixedColumnsWidth;
@property (nonatomic) CGFloat columnsWidth;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *columnWidths;

@end

@implementation HBExcelView

- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (void)setColumnWidths:(NSMutableArray<NSNumber *> *)columnWidths {
    _columnWidths = columnWidths;

    _fixedColumnsWidth = 0;
    for (NSInteger i = 0; i < _fixedColumnCount; ++i) {
        NSNumber *w1 = columnWidths[i];
        _fixedColumnsWidth += [w1 floatValue];
    }
    
    _columnsWidth = _fixedColumnsWidth;
    for (NSInteger i = _fixedColumnCount; i < columnWidths.count; ++i) {
        NSNumber *w1 = columnWidths[i];
        _columnsWidth += [w1 floatValue];
    }
}

- (void)initViewWithFrame:(CGRect)frame {
    _fixedColumnCount = 0;
    _minColumnWith = 70;
    _rightPadding = 15;
    
    _fixedColumnsWidth = 0;
    _columnsWidth = 0;

    _reusableColumnCellClasses = [NSMutableDictionary dictionary];
    _reusableColumnHeaderClasses = [NSMutableDictionary dictionary];
    _reusableColumnCells = [NSMutableDictionary dictionary];
    _reusableColumnHeaders = [NSMutableDictionary dictionary];
    
    _contentOffset = CGPointZero;

    //
    // =
    //
    _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    [self addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.alwaysBounceVertical = YES;
    _tableView.separatorInset = UIEdgeInsetsZero;
    if ([_tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        _tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    _tableView.separatorColor = [UIColor hb_colorFromHexString:@"#E1E1E1"];
    [_tableView registerNib:[UINib nibWithNibName:@"HBExcelTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [_tableView registerNib:[UINib nibWithNibName:@"HBExcelTableSectionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"header"];
    
    UIView *footerView = [_tableView hb_footerView];
    if (_blankFooterScrollView == nil) {
        _blankFooterScrollView = [[UIScrollView alloc] initWithFrame:footerView.bounds];
        [footerView addSubview:_blankFooterScrollView];
        _blankFooterScrollView.delegate = self;
        _blankFooterScrollView.showsHorizontalScrollIndicator = NO;
        _blankFooterScrollView.alwaysBounceHorizontal = YES;
        _blankFooterScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _blankFooterScrollView.contentSize = _blankFooterScrollView.bounds.size;
    }
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
    [_tableView addGestureRecognizer:_tapGestureRecognizer];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initViewWithFrame:self.frame];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViewWithFrame:frame];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _tableView.frame = self.bounds;
    
    [self updateBlankFooterScrollView];
}

- (void)updateBlankFooterScrollView {
    CGFloat footerHeight = _tableView.frame.size.height - _nonBlankContentHeight;
    if (footerHeight < 50) {
        footerHeight = 50;
    }
    
    UIView *footerView = [_tableView hb_footerView];
    CGRect frame = footerView.frame;
    
    if (footerHeight != frame.size.height) {
        frame.size.height = footerHeight;
        footerView.frame = frame;
        _tableView.tableFooterView = footerView;
        _blankFooterScrollView.contentSize = CGSizeMake(_columnsWidth+_rightPadding, footerHeight);
    }
}

#pragma mark -

- (void)setColumnWidths:(NSMutableArray<NSNumber *> *)columnWidths fixedColumnCount:(NSInteger)fixedColumnCount {
    HBAssert(fixedColumnCount < columnWidths.count, @"fixed column count should less than total column count");
    
    _fixedColumnCount = fixedColumnCount;
    self.columnWidths = columnWidths;
}

- (void)updateHeaderAtColumn:(NSInteger)column section:(NSInteger)section {
    HBExcelTableSectionHeaderView *headerView = (HBExcelTableSectionHeaderView *)[_tableView headerViewForSection:section];
    HBExcelColumnHeader *columnHeader = [headerView headerAtColumn:column];
    [columnHeader updateView];
}

- (void)reloadData {
    [_tableView reloadData];
    [_tableView hb_hideFooterLoading];
    
    CGFloat sectionsHeight = [_dataSource numberOfSectionsInExcelView:self] * [_dataSource excelView:self heightForHeaderInSection:0];
    CGFloat rowsHeight = [_dataSource numberOfRowsInExcelView:self] * [_dataSource excelView:self heightForRowAtIndexPath:nil];
    _nonBlankContentHeight = sectionsHeight + rowsHeight;
    [self updateBlankFooterScrollView];
}

- (void)registerClass:(Class)columnCellClass forReusableColumnCellIdentifier:(NSString *)identifier {
    _reusableColumnCellClasses[identifier] = columnCellClass;
}

- (void)registerClass:(Class)columnHeaderClass forReusableColumnHeaderIdentifier:(NSString *)identifier {
    _reusableColumnHeaderClasses[identifier] = columnHeaderClass;
}

- (NSArray *)datasOfRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_dataSource excelView:self datasOfRowAtIndexPath:indexPath];
}

- (NSArray *)datasOfHeaderAtSection:(NSInteger)section; {
    return [_dataSource excelView:self datasOfHeaderAtSection:section];
}

- (NSString *)cellIdetifierAtColumn:(NSInteger)column indexPath:(NSIndexPath *)indexPath headerDatas:(nonnull NSArray *)headerDatas rowDatas:(nonnull NSArray *)rowDatas {
    return [_dataSource excelView:self columnCellIdentfierAtColumn:column indexPath:indexPath headerDatas:headerDatas rowDatas:rowDatas];
}

- (NSString *)headerIdetifierAtColumn:(NSInteger)column section:(NSInteger)section headerDatas:(nonnull NSArray *)headerDatas {
    return [_dataSource excelView:self columnHeaderIdentfierAtColumn:column section:(NSInteger)section headerDatas:headerDatas];
}

- (void)enqueueReusableColumnCell:(HBExcelColumnCell *)cell {
    NSMutableArray *cells = _reusableColumnCells[cell.reuseIdentifier];
    if (cells == nil) {
        cells = [NSMutableArray arrayWithCapacity:10];
        _reusableColumnCells[cell.reuseIdentifier] = cells;
    }
    [cells addObject:cell];
}

- (HBExcelColumnCell *)dequeueReusableColumnCellWithIdentifier:(NSString *)identifier indexPath:(nonnull NSIndexPath *)indexPath {
    NSMutableArray *cells = _reusableColumnCells[identifier];
    HBExcelColumnCell *cell = cells.lastObject;
    if (cell) {
        [cells removeObject:cell];
    } else {
        Class klass = _reusableColumnCellClasses[identifier];
        if (klass) {
            cell = [[klass alloc] init];
            cell.reuseIdentifier = identifier;
        }
    }
    return cell;
}

- (HBExcelColumnCell *)dequeueReusableCellWithColumn:(NSInteger)column indexPath:(NSIndexPath *)indexPath headerDatas:(NSArray *)headerDatas rowDatas:(NSArray *)rowDatas {
    NSString *identifier = [_dataSource excelView:self columnCellIdentfierAtColumn:column indexPath:indexPath headerDatas:headerDatas rowDatas:rowDatas];
    HBExcelColumnCell *cell = [self dequeueReusableColumnCellWithIdentifier:identifier indexPath:indexPath];
    return cell;
}

- (void)enqueueReusableColumnHeader:(HBExcelColumnHeader *)header {
    NSMutableArray *cells = _reusableColumnHeaders[header.reuseIdentifier];
    if (cells == nil) {
        cells = [NSMutableArray arrayWithCapacity:10];
        _reusableColumnCells[header.reuseIdentifier] = cells;
    }
    [cells addObject:header];
}

- (HBExcelColumnHeader *)dequeueReusableColumnHeaderWithIdentifier:(NSString *)identifier section:(NSInteger)section {
    NSMutableArray *headers = _reusableColumnHeaders[identifier];
    HBExcelColumnHeader *header = headers.lastObject;
    if (header) {
        [headers removeObject:header];
    } else {
        Class klass = _reusableColumnHeaderClasses[identifier];
        if (klass) {
            header = [[klass alloc] init];
            header.reuseIdentifier = identifier;
        }
    }
    return header;
}

- (HBExcelColumnHeader *)dequeueReusableHeaderWithColumn:(NSInteger)column section:(NSInteger)section headerDatas:(NSArray *)headerDatas {
    NSString *identifier = [_dataSource excelView:self columnHeaderIdentfierAtColumn:column section:(NSInteger)section headerDatas:headerDatas];
    HBExcelColumnHeader *header = [self dequeueReusableColumnHeaderWithIdentifier:identifier section:section];
    return header;
}

#pragma mark - UIGestureRecognizer

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:_tableView];

    [_tableView.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectContainsPoint(cell.frame, point)) {
            NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
            [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self tableView:_tableView didSelectRowAtIndexPath:indexPath];
            *stop = YES;
        }
    }];
}

#pragma mark - HBExcelTableSectionHeaderViewDelegate

- (void)tableViewHeader:(HBExcelTableSectionHeaderView *)tableHeader columnWidthBeginChange:(HBExcelColumnHeader *)columnHeader {
    CGRect rect = _tableView.frame;
    rect.size.width = 2;
    rect.origin.x = columnHeader.frame.origin.x + columnHeader.frame.size.width - tableHeader.scrollView.contentOffset.x -1;
    _columnWidthChangeIndicator = [[UIView alloc] initWithFrame:rect];
    [self addSubview:_columnWidthChangeIndicator];
    _columnWidthChangeIndicator.backgroundColor = [UIColor hb_colorFromHexString:@"#2DAF5A"];
}

- (void)tableViewHeader:(HBExcelTableSectionHeaderView *)tableHeader columnWidthEndChange:(HBExcelColumnHeader *)columnHeader {
    [_columnWidthChangeIndicator removeFromSuperview];
    _columnWidthChangeIndicator = nil;
}

- (void)tableViewHeader:(HBExcelTableSectionHeaderView *)tableHeader columnWidthDidChange:(HBExcelColumnHeader *)columnHeader newWidth:(CGFloat)newWidth {
    if (newWidth < _minColumnWith) return;
    
    CGFloat oldWidth = [_columnWidths[columnHeader.column] floatValue];
    
    BOOL isLast = (columnHeader.column == ([_dataSource numberOfColumnsInExcelView:self] - 1)) && (newWidth > oldWidth);
    
    _columnWidths[columnHeader.column] = @(newWidth);
    _columnsWidth += (newWidth - oldWidth);
    
    if ([_delegate respondsToSelector:@selector(excelView:widthDidChangeOfColumnHeader:newWidth:section:)]) {
        [_delegate excelView:self widthDidChangeOfColumnHeader:columnHeader newWidth:newWidth section:tableHeader.section];
    }
    
    CGPoint contentOffset = tableHeader.scrollView.contentOffset;
    contentOffset.x += (newWidth - oldWidth);
    
    CGSize contentSize = tableHeader.scrollView.contentSize;
    contentSize.width = _columnsWidth + _rightPadding;
    
    for (HBExcelTableViewCell *cell in _tableView.visibleCells) {
        cell.scrollView.contentSize = contentSize;
        if (isLast) {
            cell.scrollView.contentOffset = contentOffset;
        }
        [cell updateVisibleCellsFromColumn:columnHeader.column];
    }

    for (NSInteger i = 0; i < _tableView.numberOfSections; ++i) {
        HBExcelTableSectionHeaderView *headerView = (HBExcelTableSectionHeaderView *)[_tableView headerViewForSection:i];
        if (headerView) {
            headerView.scrollView.contentSize = contentSize;
            
            if (isLast) {
                headerView.scrollView.contentOffset = contentOffset;
            }
            [headerView updateVisibleHeadersFromColumn:columnHeader.column];
        }
    }
    
    CGRect frame = _columnWidthChangeIndicator.frame;
    frame.origin.x = columnHeader.frame.origin.x + newWidth - tableHeader.scrollView.contentOffset.x - 1;
    _columnWidthChangeIndicator.frame = frame;
}

- (void)tableViewHeader:(HBExcelTableSectionHeaderView *)tableHeader didSelectColumnHeader:(HBExcelColumnHeader *)columnHeader   section:(NSInteger)section {
    if ([_delegate respondsToSelector:@selector(excelView:didSelectColumnHeader:section:)]) {
        [_delegate excelView:self didSelectColumnHeader:columnHeader section:(NSInteger)section];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s%ld", __PRETTY_FUNCTION__, (long)indexPath.row);
    if ([_delegate respondsToSelector:@selector(excelView:didSelectRowAtIndexPath:)]) {
        [_delegate excelView:self didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([_dataSource respondsToSelector:@selector(numberOfSectionsInExcelView:)]) {
        return [_dataSource numberOfSectionsInExcelView:self];
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([_dataSource respondsToSelector:@selector(excelView:heightForHeaderInSection:)]) {
        return [_dataSource excelView:self heightForHeaderInSection:section];
    }
    return 1.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HBExcelTableSectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    
    headerView.excelView = self;
    headerView.section = section;
    headerView.headerDelegate = self;
    headerView.scrollView.delegate = self;
    headerView.scrollView.contentSize = CGSizeMake(_columnsWidth+_rightPadding, [_dataSource excelView:self heightForHeaderInSection:section] - 1);
    headerView.scrollView.contentOffset = _contentOffset;
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataSource numberOfRowsInExcelView:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_dataSource excelView:self heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HBExcelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.excelView = self;
    cell.indexPath = indexPath;
    cell.contentView.backgroundColor = ((indexPath.row % 2) == 0 ? [UIColor whiteColor] : [UIColor hb_colorFromHexString:@"#FCFCFD"]);
    cell.scrollView.delegate = self;
    cell.scrollView.contentSize = CGSizeMake(_columnsWidth+_rightPadding, [_dataSource excelView:self heightForRowAtIndexPath:indexPath] - 1);
    cell.scrollView.contentOffset = _contentOffset;
    
    return cell;
}

#pragma mark UIScrollViewDelegate

- (void)updateScrollView:(UIScrollView *)scrollView contentOffset:(CGPoint)contentOffset {
    id<UIScrollViewDelegate> delegate = scrollView.delegate;
    scrollView.delegate = nil;
    scrollView.contentOffset = contentOffset;
    scrollView.delegate = delegate;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _tableView) {
        if (![_tableView hb_isShowFooterLoading] && ((scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom)) < 50)) {
            if ([_dataSource hasMoreRowsInExcelView:self]) {
                [_tableView hb_showFooterLoading];
                [_dataSource loadMoreRowsInExcelView:self];
            } else {
                [_tableView hb_hideFooterLoading];
            }
        }
        if ([_delegate respondsToSelector:@selector(excelView:scrollDidChange:)]) {
            [_delegate excelView:self scrollDidChange:scrollView];
        }
    } else {
        if (_draggingColumnHeader != nil) return;

        _contentOffset = scrollView.contentOffset;
        NSArray <HBExcelTableViewCell *> *cells = [_tableView visibleCells];
        [cells enumerateObjectsUsingBlock:^(HBExcelTableViewCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
            if (cell.scrollView != scrollView) {
                [self updateScrollView:cell.scrollView contentOffset:scrollView.contentOffset];
            }
        }];
        for (NSInteger i = 0; i < [_tableView numberOfSections]; ++i) {
            HBExcelTableSectionHeaderView *headerView = (HBExcelTableSectionHeaderView *)[_tableView headerViewForSection:i];
            if (headerView.scrollView != scrollView) {
                headerView.scrollView.contentOffset = scrollView.contentOffset;
            }
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

}

@end
