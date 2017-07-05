//
//  UITableView+LoadingMore.m
//  iOSDemos
//
//  Created by zhoubo on 2017/4/20.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

#import "UITableView+LoadingMore.h"

@implementation UITableView (LoadingMore)

- (UIView *)hb_footerView {
    UIView *footerView = self.tableFooterView;
    if (footerView == nil) {
        CGRect frame = self.bounds;
        frame.size.height = 1;
        footerView = [[UIView alloc] initWithFrame:frame];
        self.tableFooterView = footerView;
    }
    return footerView;
}

- (UIView *)hb_footerLoading {
    UIView *boxView = [[self hb_footerView] viewWithTag:1704201];
    if (boxView == nil) {
        boxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        [self.tableFooterView addSubview:boxView];
        boxView.hidden = YES;
        boxView.tag = 1704201;
        boxView.translatesAutoresizingMaskIntoConstraints = NO;
        NSArray *constraints = @[
                                 [NSLayoutConstraint constraintWithItem:boxView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.tableFooterView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],
                                 
                                 [NSLayoutConstraint constraintWithItem:boxView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.tableFooterView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0],
                                 
                                 [NSLayoutConstraint constraintWithItem:boxView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100],
                                 
                                 [NSLayoutConstraint constraintWithItem:boxView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:20]
                                 ];
        [self.tableFooterView addConstraints:constraints];
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [boxView addSubview:activityIndicator];
        activityIndicator.frame = CGRectMake(0, 0, 20, 20);
        activityIndicator.tag = 1704202;
        activityIndicator.hidesWhenStopped = YES;
        [activityIndicator startAnimating];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 100, 20)];
        [boxView addSubview:label];
        label.tag = 1704203;
        label.font = [UIFont systemFontOfSize:14];
        label.text = @"正在加载...";
    }
    return boxView;
}

- (BOOL)hb_isShowFooterLoading {
    UIView *boxView = [self hb_footerLoading];
    return boxView.hidden == NO;
}

- (void)hb_showFooterLoading {
    UIView *boxView = [self hb_footerLoading];
    boxView.hidden = NO;
}

- (void)hb_hideFooterLoading {
    UIView *boxView = [self hb_footerLoading];
    boxView.hidden = YES;
}

- (UIView *)hb_addFooterTopSeparator {
    UIView *separotorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
    separotorView.backgroundColor = [UIColor hb_colorFromHexString:HBSeparatorColor];
    separotorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    separotorView.tag = 1704261;
    [[self hb_footerView] addSubview:separotorView];
    return separotorView;
}

- (void)hb_hideFooterTopSeparator:(BOOL)hidden {
    UIView *separotorView = [[self hb_footerView] viewWithTag:1704261];
    if (separotorView == nil) {
        separotorView = [self hb_addFooterTopSeparator];
    }
    separotorView.hidden = hidden;
}

@end
