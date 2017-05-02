//
//  UITableView+LoadingMore.h
//  iOSDemos
//
//  Created by zhoubo on 2017/4/20.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (LoadingMore)

- (UIView *)hb_footerView;

- (UIView *)hb_footerLoading;
- (BOOL)hb_isShowFooterLoading;
- (void)hb_showFooterLoading;
- (void)hb_hideFooterLoading;

- (UIView *)hb_addFooterTopSeparator;
- (void)hb_hideFooterTopSeparator:(BOOL)hidden;

@end
