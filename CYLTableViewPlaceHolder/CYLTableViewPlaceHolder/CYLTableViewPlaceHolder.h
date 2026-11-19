//
//  CYLTableViewPlaceHolder.h
//  CYLNoResultTableViewController
//
//  Created by 微博@iOS程序犭袁 ( http://weibo.com/luohanchenyilong/ ) on 15/12/23.
//  Copyright © 2015年 https://github.com/ChenYilong . All rights reserved.
//

#import "UITableView+CYLTableViewPlaceHolder.h"
#import "CYLTableViewPlaceHolderDelegate.h"
#import "UITableView+CYLPlaceholder.h"
#import "UICollectionView+CYLPlaceholder.h"
#import "CYLPlaceholderView.h"
#import "CYLPlaceholderLocalization.h"
#import "CYLPlaceholderScenario.h"
#import "CYLPlaceholderStackView.h"
#import "CYLPlaceholderStatusView.h"
#import "CYLPlaceholderHUD.h"
#import "CYLPlaceholderNetworkMonitor.h"
#import "UIViewController+CYLPlaceholderStatus.h"
#import "CYLRefresh.h"
// [EN] Internal C functions for the module's Swift files (the legacy `cyl_reloadData`); not API.
// [CN] 供模块内 Swift 文件（旧的 `cyl_reloadData`）使用的内部 C 函数；不是 API。
#import "CYLPlaceholderVisibleArea.h"
// [EN] Internal members of CYLPlaceholderComponent for the module's Swift files (CYLPlaceholderStackView); not API.
// [CN] 供模块内 Swift 文件（CYLPlaceholderStackView）使用的 CYLPlaceholderComponent 内部成员；不是 API。
#import "CYLPlaceholderComponentInternal.h"

// [EN] CYLPlaceholderView, CYLPlaceholderLocalization, CYLPlaceholderNetworkMonitor, the legacy `cyl_reloadData` category,
//      CYLPlaceholderStatusView, CYLPlaceholderStackView and the view controller status category are Swift (2026-11-19): Objective-C code gets their interfaces from the module's generated Swift
//      header, imported last so that every Objective-C type it mentions is declared. Not for Swift (`__swift__`): the
//      module's own Swift files must not import their generated header.
// [CN] CYLPlaceholderView、CYLPlaceholderLocalization、CYLPlaceholderNetworkMonitor、旧的 `cyl_reloadData` 分类、CYLPlaceholderStatusView、
//      CYLPlaceholderStackView 与视图控制器状态分类用 Swift 编写（2026-11-19）：Objective-C 代码从模块生成的 Swift 头文件获得其接口；放在最后导入，确保其中用到的
//      Objective-C 类型都已声明。不供 Swift 使用（`__swift__`）：模块自己的 Swift 文件不能导入自己生成的头文件。
#ifndef __swift__
#if __has_include(<CYLTableViewPlaceHolder/CYLTableViewPlaceHolder-Swift.h>)
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder-Swift.h>
#elif __has_include("CYLTableViewPlaceHolder-Swift.h")
#import "CYLTableViewPlaceHolder-Swift.h"
#endif
#endif
