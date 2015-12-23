//
//  XTNetReloader.h
//  Demo_MjRefresh
//
//  Created by TuTu on 15/12/8.
//  Copyright © 2015年 teason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^ReloadButtonClickBlock)() ;

@interface XTNetReloader : UIView

- (instancetype)initWithFrame:(CGRect)frame
                  reloadBlock:(ReloadButtonClickBlock)reloadBlock ;

- (void)showInView:(UIView *)viewWillShow ;
- (void)dismiss ;

@end

