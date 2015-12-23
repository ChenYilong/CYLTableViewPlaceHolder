# CYLTableViewPlaceHolder【一行代码完成“空TableView占位视图”管理】

<p align="center">
![pod-v1.0.6](https://img.shields.io/badge/pod-v1.0.6-brightgreen.svg)
![Objective--C-compatible](https://img.shields.io/badge/Objective--C-compatible-orange.svg)   ![platform-iOS-6.0+](https://img.shields.io/badge/platform-iOS%206.0%2B-ff69b4.svg)
</a>

## 导航

  1.  [ 与其他框架的区别 ](https://github.com/ChenYilong/CYLTableViewPlaceHolder#与其他框架的区别) 
  2.  [ 集成后的效果 ](https://github.com/ChenYilong/CYLTableViewPlaceHolder#集成后的效果) 
  3.  [ 使用CYLTableViewPlaceHolder ](https://github.com/ChenYilong/CYLTableViewPlaceHolder#使用cyltableviewplaceholder) 
  3.  [ 运行Demo ](https://github.com/ChenYilong/CYLTableViewPlaceHolder#运行demo) 


## 与其他框架的区别
 -| 特点 |解释
-------------|-------------|-------------
1 | 轻量级、无污染 | 基于 UITableView 分类，无污染，比基于子类化、继承的框架更加轻量级
2 | 低耦合 | 自定义占位视图的可自行实现，通过协议传递，耦合性极低。
3 | 简单，无学习成本 | 一行代码完成，仅需使用  `cyl_reloadData`  代替  `reloadData` 即可。自动检测是否需要 `addSubview` 和 `removeFromSuperview` ，省去学习繁琐的 add 和 remove 的调用时机。
4 | 使用方法简单 |  [CYLTableViewPlaceHolder](https://github.com/ChenYilong/CYLTableViewPlaceHolder) 基于  `dataSource`  数据源，所以只需操作  `dataSource`  数据源，即可完成占位视图的 `addSubview` 和 `removeFromSuperview` 的时机，更加直观。搭配 MJRefresh 使用十分方便，demo 中也给出了搭配使用方法。
5 |支持CocoaPods |容易集成

（学习交流群：523070828）



## 集成后的效果

![集成后的效果](http://i64.tinypic.com/708hl4.jpg)

## 使用[CYLTableViewPlaceHolder](https://github.com/ChenYilong/CYLTableViewPlaceHolder)

三步完成：

  1.  [ 第一步：使用cocoaPods导入CYLTableViewPlaceHolder ](https://github.com/ChenYilong/CYLTableViewPlaceHolder#第一步使用cocoapods导入cyltableviewplaceholder) 
  2.  [第二步：遵循协议](https://github.com/ChenYilong/CYLTableViewPlaceHolder#第二步遵循协议) 
  3.  [第三步：使用cyl_reloadData代替reloadData](https://github.com/ChenYilong/CYLTableViewPlaceHolder#第三步使用cyl_reloaddata代替reloaddata) 

### 第一步：使用cocoaPods导入CYLTableViewPlaceHolder

在 `Podfile` 中如下导入：


 ```Objective-C
 pod 'CYLTableViewPlaceHolder'
 ```

然后使用 `cocoaPods` 进行安装：

建议使用如下方式：

 ```Objective-C
 # 不升级CocoaPods的spec仓库
pod update --verbose 
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


 1.   [CYLTableViewPlaceHolder](https://github.com/ChenYilong/CYLTableViewPlaceHolder) 的 `cyl_reloadData`方法内部会重新将该占位视图的 frame 进行设置，设置为与当前的的  `TableView`  一致：包括 xy 坐标和宽高。防止 `TableView`  位置或尺寸的变更。
 2. 以上步骤，包括遵循协议实现协议方法，既可以在自定义的  `TableView`  中去做，也可以在  `TableView`  的代理中去做。

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
 @brief  enable tableView scroll or not when place holder view is showing,it is disabled by default.
 @return enable tableView scroll or not
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

## 运行Demo

demo 的刷新组件使用的是 MJRefresh，所以需要导入相应的 CocoaPods 库 



 ```Objective-C
# 打开终端，进入 clone 的文件夹
cd /Users/YourUserName/Documents/CYLTableViewPlaceHolder
# 如果提示找不到库，则可去掉 --no-repo-update
pod install --verbose --no-repo-update 
open CYLTableViewPlaceHolder.xcworkspace
 ```

（更多iOS开发干货，欢迎关注  [微博@iOS程序犭袁](http://weibo.com/luohanchenyilong/) ）

----------
Posted by [微博@iOS程序犭袁](http://weibo.com/luohanchenyilong/)  
原创文章，版权声明：自由转载-非商用-非衍生-保持署名 | [Creative Commons BY-NC-ND 3.0](http://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)

