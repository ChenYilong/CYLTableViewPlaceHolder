# CYLTableViewPlaceHolder【一行代码完成“空TableView占位视图”管理】

<p align="center">
![pod-v1.0.6](https://img.shields.io/badge/pod-v1.0.6-brightgreen.svg)
![Objective--C-compatible](https://img.shields.io/badge/Objective--C-compatible-orange.svg)   ![platform-iOS-6.0+](https://img.shields.io/badge/platform-iOS%206.0%2B-ff69b4.svg)
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
4 | 使用方法简单 |  [CYLTableViewPlaceHolder](https://github.com/ChenYilong/CYLTableViewPlaceHolder) 基于  `dataSource`  数据源，所以只需操作  `dataSource`  数据源，即可完成占位视图的 `addSubview` 和 `removeFromSuperview` 的时机，更加直观。搭配 MJRefresh 使用十分方便，demo 中也给出了搭配使用方法。
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
pod 'CYLTableViewPlaceHolder'
 ```



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

自定义 frame 不会自动跟随尺寸变化，必要时请为返回的视图设置 autoresizing mask，或在布局变化后重新加载。对于 section header 和 MJRefresh footer，需根据它们在 table view 内容坐标系中的实际 frame 计算不重叠区域；例如空数据时 MJRefresh 自动 footer 不一定在屏幕底部。占位图仍位于其 frame 内其他子视图之上。

例如，在使用 `MJRefreshAutoNormalFooter` 且 footer 位于内容顶部的场景中，可在导入 MJRefresh 后将占位图放在 footer 之后：

```Objective-C
- (CGRect)frameForPlaceHolderViewInTableView:(UITableView *)tableView {
    CGFloat top = CGRectGetMaxY(tableView.mj_footer.frame);
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

本库只管理 `UITableView`，不管理 `UICollectionView` 或普通页面；这些场景需要各自的空状态实现。使用独立 data source 时，delegate 或 table view 仍可负责创建占位图，也可以让 data source 实现该协议。

## 运行Demo

demo 的刷新组件使用的是 MJRefresh，所以需要导入相应的 CocoaPods 库 

使用 `pod install` 后打开 `CYLTableViewPlaceHolder.xcworkspace`，不要打开 `.xcodeproj`。若遇到 `library not found for -lPods`，检查 workspace、Podfile 中的 target 与应用 target 是否一致，并重新执行 `pod install`；这是 CocoaPods 集成问题，不应手动链接旧的 `libPods.a`。较新的 Xcode 可能需要在构建时指定受支持的 iOS deployment target。



 ```Objective-C
# 打开终端，进入 clone 的文件夹
cd /Users/YourUserName/Documents/CYLTableViewPlaceHolder
# 如果提示找不到库，则可去掉 --no-repo-update
pod install --verbose --no-repo-update 
open CYLTableViewPlaceHolder.xcworkspace
 ```


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
