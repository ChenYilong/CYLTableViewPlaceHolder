//
//  UICollectionViewLayout+CYLRefresh.m
//
//  该类是用来解决 Footer 在底端加载完成后, 仍停留在原处的 bug.
//  此问题出现在 iOS 14 及以下系统上.
//  Reference: https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/1552
//
//  Created by jiasong on 2021/11/15.
//  Copyright © 2021 小码哥. All rights reserved.
//

#import "UICollectionViewLayout+CYLRefresh.h"
#import "CYLRefreshConst.h"
#import "CYLRefreshFooter.h"
#import "UIScrollView+CYLRefresh.h"

@implementation UICollectionViewLayout (CYLRefresh)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CYLRefreshExchangeImplementations(self.class, @selector(finalizeCollectionViewUpdates),
                                         self.class, @selector(cyl_finalizeCollectionViewUpdates));
    });
}

- (void)cyl_finalizeCollectionViewUpdates {
    [self cyl_finalizeCollectionViewUpdates];

    __kindof CYLRefreshFooter *footer = self.collectionView.cyl_footer;
    CGSize newSize = self.collectionViewContentSize;
    CGSize oldSize = self.collectionView.contentSize;
    if (footer != nil && !CGSizeEqualToSize(newSize, oldSize)) {
        NSDictionary *changed = @{
            NSKeyValueChangeNewKey: [NSValue valueWithCGSize:newSize],
            NSKeyValueChangeOldKey: [NSValue valueWithCGSize:oldSize],
        };
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [footer scrollViewContentSizeDidChange:changed];
        [CATransaction commit];
    }
}

@end
