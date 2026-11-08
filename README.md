# CYLTableViewPlaceHolder【一行代码完成“空TableView占位视图”管理】

<p align="center">
![pod-v1.0.6](https://img.shields.io/badge/pod-v1.0.6-brightgreen.svg)
![Objective--C-compatible](https://img.shields.io/badge/Objective--C-compatible-orange.svg)   ![platform-iOS-12.0+](https://img.shields.io/badge/platform-iOS%2012.0%2B-ff69b4.svg)
</a>

## 导航

  1.  [ 与其他框架的区别 ](https://github.com/ChenYilong/CYLTableViewPlaceHolder#与其他框架的区别) 
  2.  [ 集成后的效果 ](https://github.com/ChenYilong/CYLTableViewPlaceHolder#集成后的效果) 
  3.  [ 使用CYLTableViewPlaceHolder ](https://github.com/ChenYilong/CYLTableViewPlaceHolder#使用cyltableviewplaceholder) 
  4.  [ 运行Demo ](https://github.com/ChenYilong/CYLTableViewPlaceHolder#运行demo) 
  5.  [ 适用于多种应用应用场景 ](https://github.com/ChenYilong/CYLTableViewPlaceHolder#适用于多种应用应用场景) 
   1.  [ 网络故障 ](https://github.com/ChenYilong/CYLTableViewPlaceHolder#网络故障) 
   2.  [ 暂无数据 ](https://github.com/ChenYilong/CYLTableViewPlaceHolder#暂无数据) 


## 与其他框架的区别
 -| 特点 |解释
-------------|-------------|-------------
1 | 轻量级、无污染 | 基于 UITableView 分类，无污染，比基于子类化、继承的框架更加轻量级
2 | 低耦合 | 自定义占位视图的可自行实现，通过协议传递，耦合性极低。
3 | 简单，无学习成本 | 一行代码完成，仅需使用  `cyl_reloadData`  代替  `reloadData` 即可。自动检测是否需要 `addSubview` 和 `removeFromSuperview` ，省去学习繁琐的 add 和 remove 的调用时机。
4 | 使用方法简单 | 基于 `dataSource` 管理占位视图；内置的 `CYLRefresh` 提供下拉、上拉和横向刷新功能。
5 |支持CocoaPods |容易集成

（学习交流群：465239521）



## 集成后的效果

![集成后的效果](http://i64.tinypic.com/708hl4.jpg)

## 使用[CYLTableViewPlaceHolder](https://github.com/ChenYilong/CYLTableViewPlaceHolder)

三步完成：

  1.  [ 第一步：使用cocoaPods导入CYLTableViewPlaceHolder ](https://github.com/ChenYilong/CYLTableViewPlaceHolder#第一步使用cocoapods导入cyltableviewplaceholder) 
  2.  [第二步：遵循协议](https://github.com/ChenYilong/CYLTableViewPlaceHolder#第二步遵循协议) 
  3.  [第三步：使用cyl_reloadData代替reloadData](https://github.com/ChenYilong/CYLTableViewPlaceHolder#第三步使用cyl_reloaddata代替reloaddata) 


### 第一步：使用CocoaPods导入CYLTableViewPlaceHolder


在 `Podfile` 中进行如下导入：


 ```Objective-C
pod 'CYLTableViewPlaceHolder', :git => 'https://github.com/ChenYilong/CYLTableViewPlaceHolder.git', :branch => 'master'
 ```



新版本尚未发布到 CocoaPods 时，请使用上述 Git 分支或本地 `:path`；历史版本不会自动包含新功能。本库最低支持 **iOS 12**，不再需要单独添加刷新库。

然后使用 `cocoaPods` 进行安装：

如果尚未安装 CocoaPods, 运行以下命令进行安装:


 ```Objective-C
gem install cocoapods
 ```


安装成功后就可以安装依赖了：

建议使用如下方式：


 ```Objective-C
 # 禁止升级CocoaPods的spec仓库，否则会卡在 Analyzing dependencies ，非常慢 
 pod update --verbose --no-repo-update
 ```


如果提示找不到库，则可去掉 --no-repo-update


 ```Objective-C
pod update
 ```



### 第二步：遵循协议



导入头文件

 ```Objective-C
#import "CYLTableViewPlaceHolder.h"
 ```

遵循协议

 ```Objective-C
 @interface ViewController ()<CYLTableViewPlaceHolderDelegate>
 ```



实现协议方法：

仅一个必须实现的协议方法：

创建一个自定义的占位视图并返回

 ```Objective-C
@required
/*!
 @brief  make an empty overlay view when the tableView is empty
 @return an empty overlay view
 */
- (UIView *)makePlaceHolderView;
 ```

这里注意两点：


 1. 默认占位视图填满 table view 的 bounds，宽高随 table view 调整。每次空数据刷新都会重新调用 `makePlaceHolderView`，因此可以切换网络错误与无数据视图。
 2. `makePlaceHolderView` 可由自定义 table view、delegate 或独立的 data source 实现，按此顺序查找；应返回非空视图。

如果表头或刷新 footer 需要保持可见，可在提供占位图的对象中实现可选方法，返回 table view 坐标系中的区域；每次布局需求变化时调用 `cyl_reloadData` 更新区域：

```Objective-C
- (CGRect)frameForPlaceHolderViewInTableView:(UITableView *)tableView {
    CGFloat top = CGRectGetMaxY(tableView.tableHeaderView.frame);
    return CGRectMake(0, top, CGRectGetWidth(tableView.bounds),
                      MAX(0, CGRectGetHeight(tableView.bounds) - top));
}
```

自定义 frame 不会自动跟随尺寸变化，必要时请为返回的视图设置 autoresizing mask，或在布局变化后重新加载。对于 section header 和刷新 footer，需根据它们在 table view 内容坐标系中的实际 frame 计算不重叠区域；空数据时自动 footer 不一定在屏幕底部。占位图仍位于其 frame 内其他子视图之上。

例如，在使用 `CYLRefreshAutoNormalFooter` 且 footer 位于内容顶部的场景中，可将占位图放在 footer 之后：

```Objective-C
- (CGRect)frameForPlaceHolderViewInTableView:(UITableView *)tableView {
    CGFloat top = CGRectGetMaxY(tableView.cyl_footer.frame);
    return CGRectMake(0, top, CGRectGetWidth(tableView.bounds),
                      MAX(0, CGRectGetHeight(tableView.bounds) - top));
}
```

此示例不是所有布局的通用解：footer 位置变化后应重新计算；若还有表头或 section header，也需结合它们的实际位置。

 既可以让代理遵循协议，实现协议方法：

 ```Objective-C
 @interface ViewController ()<CYLTableViewPlaceHolderDelegate>
 ```

 也可以让自定义的  `TableView` 遵循协议，实现协议方法：

 ```Objective-C
 @interface MyTableView ()<CYLTableViewPlaceHolderDelegate>
 ```

 这里推荐在自定义的 `TableView` 中实现，以降低耦合性，同时也可以为 Controller 瘦身。

占位视图的点击事件等，请自行在 `- (UIView *)makePlaceHolderView;` 中所创建的 View 中实现。

另外，占位视图默认的设置是不能滚动的，也就不能下拉刷新了，但是如果想让占位视图可以滚动，则需要实现下面的可选代理方法。

 ```Objective-C
@optional
/*!
 @brief enable tableView scroll when place holder view is showing,it is disabled by default.
 @return YES 表示可滚动，NO 表示不可滚动
 */
- (BOOL)enableScrollWhenPlaceHolderViewShowing;
 ```



### 第三步：使用cyl_reloadData代替reloadData

使用方法：

仅需使用  `cyl_reloadData`  代替  `reloadData` 即可。

 ```Objective-C
    [self.tableView cyl_reloadData];
 ```

注意：  `cyl_reloadData`  内部已经实现了   `[self.tableView reloadData]; ` 方法，请避免重复调用。

占位图功能只管理 `UITableView`，不管理 `UICollectionView` 或普通页面；这些场景需要各自的空状态实现。使用独立 data source 时，delegate 或 table view 仍可负责创建占位图，也可以让 data source 实现该协议。

## 内置刷新组件

`CYLRefresh` 源码位于 `CYLTableViewPlaceHolder/CYLRefresh/`，可直接修改，无需安装额外的刷新 Pod。导入 `CYLTableViewPlaceHolder.h` 后：

```Objective-C
self.tableView.cyl_header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{
    // 加载数据，完成后调用 endRefreshing
}];
self.tableView.cyl_footer = [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{
    // 加载更多数据，完成后调用 endRefreshing
}];
```

原刷新库 API 已改名：类名前缀改为 `CYL`，分类属性和方法使用 `cyl_`。这是一次 API 不兼容的迁移：应用中的旧类名、属性、分类方法及自定义本地化 key 需要相应修改。分类上的旧版无前缀 `header` / `footer` 不再提供。使用源码手动集成时，除所有 `.h`、`.m` 外，还须将 `CYLRefresh` 目录及其子目录加入 Header Search Paths，并复制 `CYLRefresh.bundle`、`PrivacyInfo.xcprivacy` 和 `LICENSE.third-party` 到应用资源。静态库集成需要使用 `-ObjC` 链接分类。

`endRefreshing`、`endRefreshingWithNoMoreData` 和 `resetNoMoreData` 在主线程立即更新状态；从后台线程调用时仍异步提交到主队列。自动 footer 在 header 正在刷新时不会自动触发，但这不是所有 header/footer 类型的双向互斥。

开启分页时，自动 footer 结束刷新不会再直接减去整个底部 inset：静止时只将超出正常内容范围的 offset 限制回边界；拖拽或减速期间不主动改写 offset，由滚动视图完成回弹。

从横向刷新切换到纵向刷新时，应先设置 `scrollView.cyl_trailer = nil`，再配置纵向 footer。移除正在刷新的 trailer 会先结束刷新，撤回它增加的右侧 inset，并恢复之前的横向弹性滚动设置；同时保留调用方之后对 inset 所做的修改。如果在开始动画完成前结束或移除 trailer，该次刷新回调和开始完成回调不会执行，结束完成回调仍会执行。复用 trailer 时，旧动画不会触发新一轮刷新回调或重置新一轮的拉动进度；重叠的结束动画分别调用各自开始时的完成回调。

需要跟踪滚动方向时，先调用一次 `[scrollView cyl_updateScrollMetrics]` 建立基准，再在每次 `scrollViewDidScroll:` 中调用一次；`cyl_scrollDistance` 和 `cyl_scrollDirection` 可重复读取同一次采样。距离为主导轴上的带符号点数，方向表示 content offset 的变化方向；首次采样距离为零，方向为 `CYLScrollDirectionNone`。

刷新组件依据本地源码中声明的 3.7.9 版本改造，适用第三方 MIT 许可证；原版权声明、许可证及来源说明保留在源码和 `CYLRefresh/LICENSE.third-party` 中。

## 运行Demo

Demo 已直接编译刷新源码，打开 `CYLTableViewPlaceHolder.xcodeproj` 或 workspace 即可，无需运行 `pod install`。较新的 Xcode 可能需要在构建时指定其支持的模拟器 deployment target。


## 适用于多种应用应用场景

[CYLTableViewPlaceHolder](https://github.com/ChenYilong/CYLTableViewPlaceHolder) 是基于  `dataSource`  数据源是否为空，所以只需操作  `dataSource`  数据源，即可完成占位视图的 `。只要为空就会触发。并且每次在操作占位视图的 `addSubview` 和 `removeFromSuperview` 时，每次都会将旧的销毁，并触发 `- (UIView *)makePlaceHolderView` 创建一个新的视图。如果在该方法中进行 if 判断，也就能适用于不同的场景。

   1.  [ 网络故障 ](https://github.com/ChenYilong/CYLTableViewPlaceHolder#网络故障) 
    1.  [ 网络不可用，禁止重新加载 ](https://github.com/ChenYilong/CYLTableViewPlaceHolder#网络不可用禁止重新加载) 
   2.  [ 暂无数据 ](https://github.com/ChenYilong/CYLTableViewPlaceHolder#暂无数据) 

### 网络故障

适用于那些造成 dataSource 为空的原因只能是网络故障，比如首页、团购列表、商品列表等

比如

携程 网络故障 | 携程 网络故障 | 携程 网络故障
-------------|-------------|-------------
![应用场景之加载失败--携程](http://a66.tinypic.com/309791e.jpg) | ![应用场景之加载失败--携程](http://a67.tinypic.com/2druukl.jpg) | ![应用场景之加载失败--携程](http://a68.tinypic.com/11kz5vd.jpg)

代码实现时直接返回网络故障占位视图，用伪代码表示则是：

 ```Objective-C
- (UIView *)makePlaceHolderView {
        return NetNotAvailableView;
}
 ```



#### 网络不可用，禁止重新加载

如果此时检测到网络断开可以禁止用户刷新的行为，比如：

QQ空间 | 苏宁易购 | 嘟嘟美甲
-------------|-------------|-------------
![应用场景之加载失败](http://a64.tinypic.com/2ltrh3p.jpg) |![应用场景之加载失败](http://a66.tinypic.com/f2sx9g.jpg) |![应用场景之加载失败](http://a65.tinypic.com/w9e71d.jpg)|




### 暂无数据

适用于那些造成 dataSource 为空的原因不仅有网络故障，也可能是确实是服务端也没有数据，这种场景下需要判断下当前网络再返回占位视图，比如：




App | 暂无数据 | 网络故障
 -------------|------------- | ---------
百度传课 | ![应用场景之暂无数据](http://a63.tinypic.com/24x2jh1.jpg) |![应用场景之加载失败](http://a68.tinypic.com/34qnx8w.jpg)



 暂无数据 | 暂无数据（美团）
-------------|-------------
![应用场景之暂无数据](http://a64.tinypic.com/2i6dqtl.jpg) | ![应用场景之暂无数据](http://a67.tinypic.com/bhefd5.jpg)


代码实现，用伪代码表示则是：


 ```Objective-C
- (UIView *)makePlaceHolderView {
    if (NetNotAvailable) {
        return NetNotAvailableView;
    } else {
        return NoDataView;
    }
}
 ```


### 网络不可达场景


- | 应用场景之加载失败 |  ---
-------------|-------------|-------------
![应用场景之加载失败](http://a65.tinypic.com/2nqbors.jpg) | ![应用场景之加载失败](http://a64.tinypic.com/17edlv.jpg) | ![应用场景之加载失败](http://a67.tinypic.com/2zg5hrr.jpg)
![应用场景之加载失败](http://a67.tinypic.com/2qx2ryo.jpg) | ![应用场景之加载失败](http://a64.tinypic.com/ms198y.jpg) | ![应用场景之加载失败](http://a66.tinypic.com/2r5eoig.jpg)
![应用场景之加载失败](http://a68.tinypic.com/sblk02.jpg) | ![应用场景之加载失败](http://a64.tinypic.com/2lvfq4y.jpg) | ![应用场景之加载失败](http://a63.tinypic.com/i70g13.jpg)
![应用场景之加载失败](http://a67.tinypic.com/px93s.jpg) | ![应用场景之加载失败](http://a66.tinypic.com/2ai1di.jpg) | ![应用场景之加载失败](http://a68.tinypic.com/mlmukm.jpg)
![应用场景之加载失败](http://a66.tinypic.com/6qxq36.jpg) | ![应用场景之加载失败](http://a66.tinypic.com/68bz7q.jpg) | ![应用场景之加载失败](http://a64.tinypic.com/2qu0yo1.jpg)
![应用场景之加载失败](http://a66.tinypic.com/2h3q4wh.jpg) | ![应用场景之加载失败](http://a65.tinypic.com/2w4b6ag.jpg) | ![应用场景之加载失败](http://a68.tinypic.com/28v9fdw.jpg)
![应用场景之加载失败](http://a65.tinypic.com/311xa9j.jpg) | ![应用场景之加载失败](http://a65.tinypic.com/2zf1g1l.jpg) | ![应用场景之加载失败](http://a63.tinypic.com/11udmbs.jpg)
![应用场景之加载失败](http://a63.tinypic.com/zx703l.jpg) | ![应用场景之加载失败](http://a63.tinypic.com/2chs3uc.jpg) | ![应用场景之加载失败](http://a68.tinypic.com/2a68kty.jpg)
![应用场景之加载失败](http://a67.tinypic.com/htfh1w.jpg) | ![应用场景之加载失败](http://a68.tinypic.com/1zgpykw.jpg)| ![应用场景之加载失败](http://a64.tinypic.com/xgfgi1.jpg)
![应用场景之加载失败](http://a65.tinypic.com/34gk4gm.jpg) | ![应用场景之加载失败](http://a68.tinypic.com/20abals.jpg)|![应用场景之加载失败](http://a68.tinypic.com/2up75hw.jpg)
![应用场景之加载失败](http://a66.tinypic.com/4l0bnt.jpg)| ![应用场景之加载失败](http://a67.tinypic.com/20q11th.jpg) |![应用场景之加载失败](http://a63.tinypic.com/o9o3cw.jpg)



（更多iOS开发干货，欢迎关注  [微博@iOS程序犭袁](http://weibo.com/luohanchenyilong/) ）

----------
Posted by [微博@iOS程序犭袁](http://weibo.com/luohanchenyilong/)  
原创文章，版权声明：自由转载-非商用-非衍生-保持署名 | [Creative Commons BY-NC-ND 3.0](http://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)
