//
//  ViewController.m
//  HBExcelView
//
//  Created by zhoubo on 2017/5/2.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import "ViewController.h"
#import "HBExcelView.h"

static const NSInteger kHBColumnCount = 50;
static const NSInteger kHBRowCount = 100;

@interface ViewController () <HBExcelViewDelegate, HBExcelViewDataSource>
@property (weak, nonatomic) IBOutlet HBExcelView *excelView;

@property (strong, nonatomic) NSMutableArray *headerDatas;
@property (strong, nonatomic) NSMutableArray *rowDatas;
@property (nonatomic) NSInteger offset;

@property (strong, nonatomic) NSMutableDictionary *selectedHeaderData;

@end

@implementation ViewController

- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)refreshControlDidChange:(id)sender {
    UIRefreshControl *refreshControl = (UIRefreshControl *)sender;
    
    _offset = 0;
    [self updateHeaderDatas];
    [self loadMoreRows];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [refreshControl endRefreshing];
    });
}

- (void)updateHeaderDatas {
    NSMutableArray *columnWidths = [NSMutableArray arrayWithCapacity:kHBColumnCount+1];
    _headerDatas = [NSMutableArray arrayWithCapacity:kHBColumnCount+1];
    
    [_headerDatas insertObject:@{@"name":@""
//                                 ,@"cell":@"h0"
                                 } atIndex:0];
    [columnWidths insertObject:@45 atIndex:0];
    
    for (NSInteger i = 0; i < kHBColumnCount; ++i) {
        [_headerDatas addObject:[@{@"name":[NSString stringWithFormat:@"C%ld", i+1]
//                                   ,@"cell":@"h1"
                                   } mutableCopy]];
        [columnWidths addObject:@100];
    }
    
    [_excelView setColumnWidths:columnWidths fixedColumnCount:1];
}

- (void)loadMoreRows {
    if (_offset == 0) {
        _rowDatas = [NSMutableArray arrayWithCapacity:20];
    }

    for (NSInteger i = _offset; i < _offset+20; ++i) {
        NSMutableArray *row = [NSMutableArray arrayWithCapacity:kHBColumnCount];
        [row addObject:@{@"value":@(i+1)
//                         ,@"cell":@"c0"
                         }];
        for (NSInteger j = 0; j < kHBColumnCount+1; ++j) {
            [row addObject:@{@"value":[NSString stringWithFormat:@"%ld,%ld", i, j]
//                             ,@"cell":@"cn"
                             }];
        }
        [_rowDatas addObject:row];
    }

    [_excelView reloadData];
    
    _offset += 20;
}

- (void)initData {
    _offset = 0;
    
    [self updateHeaderDatas];
    [self loadMoreRows];
}

- (void)initView {
    self.title = @"Demo ExcelView";
    
    _excelView.delegate = self;
    _excelView.dataSource = self;
    _excelView.tableView.backgroundColor = self.view.backgroundColor;
    [_excelView.tableView hb_hideFooterTopSeparator:NO];
    [_excelView registerClass:[HBExcelColumnNumberCell class] forReusableColumnCellIdentifier:@"c0"];
    [_excelView registerClass:[HBExcelColumnLabelCell class] forReusableColumnCellIdentifier:@"cn"];
    [_excelView registerClass:[HBExcelColumnHeader class] forReusableColumnHeaderIdentifier:@"h0"];
    [_excelView registerClass:[HBExcelColumnLabelHeader class] forReusableColumnHeaderIdentifier:@"hn"];
    _excelView.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshControlDidChange:) forControlEvents:UIControlEventValueChanged];
    [_excelView.tableView addSubview:refreshControl];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initView];
}

#pragma mark - HBExcelViewDelegate

- (void)excelView:(HBExcelView *)excelView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)excelView:(HBExcelView *)excelView didSelectColumnHeader:(HBExcelColumnHeader *)columnHeader section:(NSInteger)section {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSMutableDictionary *headerData = _headerDatas[columnHeader.column];
    NSInteger order = [headerData[@"order__"] integerValue];
    order = (order + 1) % 3;
    headerData[@"order__"] = @(order);
    
    // do something ...
    
    [_excelView updateHeaderAtColumn:columnHeader.column section:section];
    
    if (_selectedHeaderData != headerData) {
        if (_selectedHeaderData && [_selectedHeaderData[@"order__"] integerValue] != HBExcelColumnOrderNone) {
            _selectedHeaderData[@"order__"] = HBExcelColumnOrderNone;
            NSInteger column = [_headerDatas indexOfObject:_selectedHeaderData];
            if (column != NSNotFound) {
                [_excelView updateHeaderAtColumn:column section:section];
            }
        }
    }
    
    _selectedHeaderData = headerData;
}

- (void)excelView:(HBExcelView *)excelView widthDidChangeOfColumnHeader:(HBExcelColumnHeader *)columnHeader newWidth:(CGFloat)newWidth section:(NSInteger)section {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)excelView:(HBExcelView *)excelView scrollDidChange:(UIScrollView *)scrollView {

}

#pragma mark - HBExcelViewDataSource

- (CGFloat)excelView:(HBExcelView *)excelView heightForHeaderInSection:(NSInteger)section {
    return 45.f;
}

- (CGFloat)excelView:(HBExcelView *)excelView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.f;
}

- (NSInteger)numberOfSectionsInExcelView:(HBExcelView *)excelView {
    return 1;
}

- (NSInteger)numberOfColumnsInExcelView:(HBExcelView *)excelView {
    return _headerDatas.count;
}

- (NSArray *)excelView:(HBExcelView *)excelView datasOfHeaderAtSection:(NSInteger)section; {
    return _headerDatas;
}

- (NSInteger)numberOfRowsInExcelView:(HBExcelView *)excelView {
    return _rowDatas.count;
}

- (NSArray *)excelView:(HBExcelView *)excelView datasOfRowAtIndexPath:(NSIndexPath *)indexPath {
    return _rowDatas[indexPath.row];
}

- (NSString *)excelView:(HBExcelView *)excelView columnHeaderIdentfierAtColumn:(NSInteger)column section:(NSInteger)section headerDatas:(NSArray *)headerDatas {
    
    return column == 0 ? @"h0" : @"hn";
}

- (NSString *)excelView:(HBExcelView *)excelView columnCellIdentfierAtColumn:(NSInteger)column indexPath:(NSIndexPath *)indexPath headerDatas:(NSArray *)headerDatas rowDatas:(NSArray *)rowDatas {
    return column == 0 ? @"c0" : @"cn";
}

- (BOOL)hasMoreRowsInExcelView:(HBExcelView *)excelView {
    return _offset < kHBRowCount;
}

- (void)loadMoreRowsInExcelView:(HBExcelView *)excelView {
    [self loadMoreRows];
}

@end
