//
//  XTNetReloader.m
//  Demo_MjRefresh
//
//  Created by TuTu on 15/12/8.
//  Copyright © 2015年 teason. All rights reserved.
//

#define NO_WIFI_WORDS                   @"网络不太顺畅喔~"

float const width_displayNoWifiView  = 200.0 ;
float const height_displayNoWifiView = 150.0 ;

float const width_labelshow          = 300.0 ;
float const height_labelshow         = 35.0 ;
float const fontSize_labelshow       = 17.0 ;

float const flexY_lb_bt              = 10.0 ;

float const width_bt                 = 100.0 ;
float const height_bt                = 30.0 ;
float const fontSize_bt              = 15.0 ;

#import "XTNetReloader.h"

@interface XTNetReloader ()

@property (nonatomic, strong) UIImageView *nowifiImgView ;
@property (nonatomic, strong) UILabel *lb ;
@property (nonatomic, strong) UIButton *bt ;
@property (nonatomic, copy) ReloadButtonClickBlock reloadButtonClickBlock ;

@end

@implementation XTNetReloader

- (void)showInView:(UIView *)viewWillShow {
    [viewWillShow addSubview:self] ;
}

- (void)dismiss {
    [self removeFromSuperview] ;
}

- (instancetype)initWithFrame:(CGRect)frame
                  reloadBlock:(ReloadButtonClickBlock)reloadBlock {
    self = [super initWithFrame:frame];
    if (self) {
        self.reloadButtonClickBlock = reloadBlock ;
        [self setup] ;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews] ;
    
    CGRect rectWifi = CGRectZero ;
    rectWifi.size = CGSizeMake(width_displayNoWifiView, height_displayNoWifiView) ;
    rectWifi.origin.x = (self.frame.size.width - width_displayNoWifiView) / 2.0 ;
    rectWifi.origin.y = (self.frame.size.height - height_displayNoWifiView - height_labelshow - flexY_lb_bt - height_bt) / 2.0 ;
    self.nowifiImgView.frame = rectWifi ;
    
    CGRect rectLabel = CGRectZero ;
    rectLabel.origin.x = (self.frame.size.width - width_labelshow) / 2.0 ;
    rectLabel.origin.y = rectWifi.origin.y + rectWifi.size.height ;
    rectLabel.size = CGSizeMake(width_labelshow, height_labelshow) ;
    self.lb.frame = rectLabel ;
    
    CGRect rectButton = CGRectZero ;
    rectButton.origin.x = (self.frame.size.width - width_bt) / 2.0 ;
    rectButton.origin.y = rectLabel.origin.y + rectLabel.size.height + flexY_lb_bt ;
    rectButton.size = CGSizeMake(width_bt, height_bt) ;
    self.bt.frame = rectButton ;
}

- (void)setup {
    [self configure] ;
    [self nowifiImgView] ;
    [self lb] ;
    [self bt] ;
}

- (void)configure {
    self.backgroundColor = [UIColor whiteColor] ;
}

- (UIImageView *)nowifiImgView {
    if (!_nowifiImgView) {
        _nowifiImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no-wifi"]] ;
        _nowifiImgView.contentMode = UIViewContentModeScaleAspectFit ;
        if (![_nowifiImgView superview]) {
            [self addSubview:_nowifiImgView] ;
        }
    }
    return _nowifiImgView ;
}

- (UILabel *)lb {
    if (!_lb) {
        _lb = [[UILabel alloc] init] ;
        _lb.text = NO_WIFI_WORDS ;
        _lb.font = [UIFont boldSystemFontOfSize:fontSize_labelshow] ;
        _lb.textAlignment = NSTextAlignmentCenter ;
        _lb.textColor = [UIColor darkGrayColor] ;
        if (![_lb superview]) {
            [self addSubview:_lb] ;
        }
    }
    return _lb ;
}

- (UIButton *)bt {
    if (!_bt) {
        _bt = [[UIButton alloc] init] ;
        [_bt setTitle:@"重新加载" forState:0] ;
        [_bt setTitleColor:[UIColor darkGrayColor] forState:0] ;
        _bt.titleLabel.font = [UIFont systemFontOfSize:fontSize_bt] ;
        _bt.layer.cornerRadius = 5.0f ;
        _bt.layer.borderWidth = 1.0f ;
        _bt.layer.borderColor = [UIColor darkGrayColor].CGColor ;
        [_bt addTarget:self action:@selector(reloadButtonClicked) forControlEvents:UIControlEventTouchUpInside] ;
        if (![_bt superview]) {
            [self addSubview:_bt] ;
        }
    }
    return _bt ;
}

- (void)reloadButtonClicked {
    self.reloadButtonClickBlock() ;
}

@end




