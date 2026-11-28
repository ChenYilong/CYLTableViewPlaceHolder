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

// [EN] CYLPlaceholderView, CYLPlaceholderLocalization, CYLPlaceholderNetworkMonitor, the legacy `cyl_reloadData` category,
//      CYLPlaceholderStatusView, CYLPlaceholderStackView, the view controller status category, CYLPlaceholderComponent,
//      CYLPlaceholderScenarioCatalog, CYLPlaceholderHUD, the refresh controls (CYLRefreshComponent and every subclass, 2026-11-20), the automatic placeholder (UITableView / UICollectionView
//      `cyl_placeholderViewBlock:`, `UIScrollView (CYLPlaceholderVisibility)`) and the CYLRefresh root (CYLRefreshConfig and the
//      `UIView` / `UIScrollView` / `NSBundle` / `UICollectionViewLayout` categories) are Swift (2026-11-19): Objective-C code gets their interfaces from the module's generated Swift
//      header, imported last so that every Objective-C type it mentions is declared. Not for Swift (`__swift__`): the
//      module's own Swift files must not import their generated header.
// [CN] CYLPlaceholderView、CYLPlaceholderLocalization、CYLPlaceholderNetworkMonitor、旧的 `cyl_reloadData` 分类、CYLPlaceholderStatusView、
//      CYLPlaceholderStackView、视图控制器状态分类、CYLPlaceholderComponent、CYLPlaceholderScenarioCatalog、CYLPlaceholderHUD、自动占位图与 CYLRefresh 根目录（CYLRefreshConfig 及
//      `UIView` / `UIScrollView` / `NSBundle` / `UICollectionViewLayout` 分类）用 Swift 编写（2026-11-19）：Objective-C 代码从模块生成的 Swift 头文件获得其接口；放在最后导入，确保其中用到的
//      Objective-C 类型都已声明。不供 Swift 使用（`__swift__`）：模块自己的 Swift 文件不能导入自己生成的头文件。
#ifndef __swift__
// [EN] The generated header declares CYLRefreshGameStartScene as a subclass of SpriteKit's SKScene; an Objective-C file
//      built without modules does not get SpriteKit from it, so import it first (the podspec links SpriteKit).
// [CN] 生成的头文件把 CYLRefreshGameStartScene 声明为 SpriteKit 的 SKScene 子类；未启用模块编译的 Objective-C 文件不会因此得到
//      SpriteKit，因此先导入它（podspec 已链接 SpriteKit）。
#import <SpriteKit/SpriteKit.h>
#if __has_include(<CYLTableViewPlaceHolder/CYLTableViewPlaceHolder-Swift.h>)
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder-Swift.h>
#elif __has_include("CYLTableViewPlaceHolder-Swift.h")
#import "CYLTableViewPlaceHolder-Swift.h"
#endif
#endif
// [EN] Categories of Swift classes that only Objective-C can declare (variadic methods), after the generated header that
//      declares their classes; empty for Swift (each declares itself only outside `__swift__`), but always included,
//      so the umbrella header covers every public header of the module.
// [CN] 只有 Objective-C 能声明的 Swift 类的分类（可变参数方法），放在声明其类的生成头文件之后；对 Swift 为空（各分类只在 `__swift__`
//      之外声明），但始终导入，使总头文件包含模块的每个公开头文件。
#import "CYLRefreshDrawnHeader+CYLStatusList.h"
#import "CYLRefreshComponent+CYLPhaseList.h"
