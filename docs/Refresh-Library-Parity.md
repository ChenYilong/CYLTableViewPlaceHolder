# 刷新库对齐 / Refresh library parity

<!-- bound-classes: CYLRefreshComponent, CYLRefreshHeader, CYLRefreshFooter -->

<!-- docs-navigation:start -->

| 中文 | English |
| --- | --- |
| [任务](#任务--tasks) | [Tasks](#任务--tasks) |
| [SmartRefreshControl 对照表](#smartrefreshcontrol-对照表--smartrefreshcontrol-comparison) | [SmartRefreshControl comparison](#smartrefreshcontrol-对照表--smartrefreshcontrol-comparison) |

<!-- docs-navigation:end -->

<!-- docs-binding:start -->

| 类 / Class | 头文件 / Header |
| --- | --- |
| `CYLRefreshComponent` | [`CYLTableViewPlaceHolder/CYLRefresh/Base/CYLRefreshComponent.h`](../CYLTableViewPlaceHolder/CYLRefresh/Base/CYLRefreshComponent.h) |
| `CYLRefreshHeader` | [`CYLTableViewPlaceHolder/CYLRefresh/Base/CYLRefreshHeader.h`](../CYLTableViewPlaceHolder/CYLRefresh/Base/CYLRefreshHeader.h) |
| `CYLRefreshFooter` | [`CYLTableViewPlaceHolder/CYLRefresh/Base/CYLRefreshFooter.h`](../CYLTableViewPlaceHolder/CYLRefresh/Base/CYLRefreshFooter.h) |

<!-- docs-binding:end -->

## 任务 / Tasks

### TODO：对齐 SmartRefreshControl 并复刻其示例 / TODO: Match SmartRefreshControl and port its demo

| 中文 | English |
| --- | --- |
| 状态：进行中（2026-11-12 开始，分支 `feat/smartrefresh-parity`，来源分支 `claude/docs-todo-completion-xoef38`）。 | Status: in progress (started 2026-11-12, branch `feat/smartrefresh-parity`, source branch `claude/docs-todo-completion-xoef38`). |
| 用户原始提示词：“注意本任务主要针对 CYLRefresh文件夹代码修改 ：阅读该项目代码 以及readme <https://github.com/scwang90/SmartRefreshControl>  加入我们缺失的功能。第二步对齐api ，学习该项目的初始化方式，新增我们原有api。保证我们得功能要比这个项目更多，绝对不能少。docs中写个表格，第一列为SmartRefreshControl的公开api，第二列为我们的api。如果能找到对应的，就列出，最后查看我们少了什么API。如果SmartRefreshControl API 完全存在对应版本，那么就满分，持续更新我们的API，一直到100分 。满分后的，将SmartRefreshControl 里面的example完全复刻为swift版本 加入我们的example 。包括截图里的两个场景。优先更新core层面代码，example仅仅负责数据传入以及样式参数输入，点击事件实现。” | The user's original prompt (Chinese, verbatim on the left): mainly change the code in the CYLRefresh folder. Read SmartRefreshControl's code and README and add the features we lack. Then align the API: learn its way of initializing and add it next to our existing API. Our features must be a superset, never fewer. Write a table in docs: column 1 SmartRefreshControl's public API, column 2 ours; list the match where one exists, then see which API we lack. Full marks when every SmartRefreshControl API has a counterpart; keep adding API until 100. After full marks, port SmartRefreshControl's example completely to Swift into our example, including the two scenarios in the screenshot. Core code first; the example only passes data and style parameters and handles taps. |
| 追加提示词（同一任务中）：“同样要求处理： <https://github.com/xuelongqy/flutter_easy_refresh> 新建表格打分 复刻demo” | Added prompt (same task): treat <https://github.com/xuelongqy/flutter_easy_refresh> the same way: a new scored table, and port its demo. |
| 要求：①只改 `CYLTableViewPlaceHolder/CYLRefresh`（核心优先），示例只传数据、样式参数和点击处理；②补齐缺失功能，学习 `attach` 式初始化并新增到现有 API 旁；③表格：SmartRefreshControl 公开 API → 我们的 API，算分，补到 100；④满分后用 Swift 完整复刻其 demo（含截图中的两个场景）；⑤flutter_easy_refresh 同样处理：新表格、打分、复刻 demo；⑥功能只能比对方多。 | Requirements: (1) change only `CYLTableViewPlaceHolder/CYLRefresh` (core first); the example only passes data and style parameters and handles taps; (2) add the missing features, learn the `attach`-style initialization and add it next to the existing API; (3) table: SmartRefreshControl's public API → ours, scored, raised to 100; (4) after 100, port its demo completely to Swift (including the two scenarios in the screenshot); (5) the same for flutter_easy_refresh: a new table, a score, a demo port; (6) we may only have more features, never fewer. |
| 上下文：SmartRefreshControl（MIT，`9319448`，2022-07-07）是 Objective-C，约 9,300 行：基类 `UIRefreshComponent`（UIControl）/ `UIRefreshHeader` / `UIRefreshFooter`，经典样式 `UIRefreshClassicsHeader/Footer`，以及 12 个手绘矢量动画头（Delivery、Material、BezierRadar、BezierCircle、Fly、DropBox、Phoenix、Taurus、BattleCity、HitBlock、StoreHouse、WaveSwipe）与 Original；demo 是 Swift（每个样式一个控制器）。flutter_easy_refresh（MIT，`dcdbb81`，2026-10-23）是 Dart：核心包约 10,700 行（`EasyRefresh`、`EasyRefreshController`、`IndicatorMode`、Classic/Bezier/Material/Cupertino/Phoenix/Taurus/Delivery 等样式、二楼、多种触发模式），另有 6 个 Rive 样式包和 `easy_paging`；示例 49 个 Dart 文件（样式页、聊天、轮播、PageView、嵌套、二楼、主题切换、分页等）。用户提到的“截图里的两个场景”：本条消息未附截图，待确认。待用户决定：手绘矢量动画头需要自定义绘制视图，而 “Reuse CYLPlaceholderView in the core” 规定自定义视图需明确同意。 | Context: SmartRefreshControl (MIT, `9319448`, 2022-07-07) is Objective-C, about 9,300 lines: base classes `UIRefreshComponent` (a UIControl) / `UIRefreshHeader` / `UIRefreshFooter`, the classic `UIRefreshClassicsHeader/Footer`, and 12 hand-drawn vector headers (Delivery, Material, BezierRadar, BezierCircle, Fly, DropBox, Phoenix, Taurus, BattleCity, HitBlock, StoreHouse, WaveSwipe) plus Original; its demo is Swift (one controller per style). flutter_easy_refresh (MIT, `dcdbb81`, 2026-10-23) is Dart: the core package is about 10,700 lines (`EasyRefresh`, `EasyRefreshController`, `IndicatorMode`, Classic/Bezier/Material/Cupertino/Phoenix/Taurus/Delivery styles, a second floor, several trigger modes), plus 6 Rive style packages and `easy_paging`; its example has 49 Dart files (style pages, chat, carousel, PageView, nesting, second floor, theme switch, paging…). The "two scenarios in the screenshot": no screenshot came with this message; to confirm. For the user to decide: the hand-drawn vector headers need custom drawing views, and "Reuse CYLPlaceholderView in the core" requires explicit approval for a custom view. |
| 进度：①分支与 PR（#25）✅；②SmartRefreshControl 表格与评分 ✅（77/100）；③核心补齐基类 API ✅：`attach` 系列、`addTarget:action:`、`refreshingHandler`、`triggerRate`、`finishDuration` 与 `endRefreshingWithSuccess:`（含七种语言的完成 / 失败文字）、`scrollMode`、`colorAccent` / `colorPrimary`、`phase` 与 `isInPhases:`、`expandHeight` / `dragOffset`、可写 `lastUpdatedTime`、`lastUpdatedTimeFormatter`、`titleTimeSpacing`、`isNoMoreData` 与 7 个子类钩子；新增 `Tests/CYLRefreshSmartAPITests.m`（5 个测试），150 个测试在 iOS 27.2 通过；④手绘样式：待用户同意（13 个样式，约 7,000 行 Objective-C）；⑤示例复刻：待④完成；⑥flutter_easy_refresh：未开始。 | Progress: (1) branch and PR (#25) ✅; (2) SmartRefreshControl table and score ✅ (77/100); (3) the base-class API in the core ✅: the `attach` family, `addTarget:action:`, `refreshingHandler`, `triggerRate`, `finishDuration` with `endRefreshingWithSuccess:` (done / failed texts in seven languages), `scrollMode`, `colorAccent` / `colorPrimary`, `phase` and `isInPhases:`, `expandHeight` / `dragOffset`, writable `lastUpdatedTime`, `lastUpdatedTimeFormatter`, `titleTimeSpacing`, `isNoMoreData` and 7 subclass hooks; new `Tests/CYLRefreshSmartAPITests.m` (5 tests), 150 tests pass on iOS 27.2; (4) the hand-drawn styles: waiting for the user's approval (13 styles, about 7,000 lines of Objective-C); (5) the demo port: after (4); (6) flutter_easy_refresh: not started. |

## SmartRefreshControl 对照表 / SmartRefreshControl comparison

| 中文 | English |
| --- | --- |
| 评分：**77/100**（43/56 行有对应 API，2026-11-12，`feat/smartrefresh-parity`）。每行是一组相关的公开 API（按 SmartRefreshControl 头文件 `UIRefreshComponent.h`、`UIRefreshHeader.h`、`UIRefreshFooter.h`、`UIRefreshClassics*.h` 及各样式头文件分组）；一行全部有对应才算对齐。缺的全部是手绘矢量动画样式（最后 13 行），需要自定义绘制视图，见上方任务中的待决定事项。 | Score: **77/100** (43 of 56 rows have a counterpart, 2026-11-12, `feat/smartrefresh-parity`). Each row is one group of related public API (grouped by SmartRefreshControl's headers `UIRefreshComponent.h`, `UIRefreshHeader.h`, `UIRefreshFooter.h`, `UIRefreshClassics*.h` and the style headers); a row counts only when all of it has a counterpart. Everything missing is a hand-drawn vector style (the last 13 rows), which needs custom drawing views; see the open decision in the task above. |
| 我们多出的功能（对方没有）：trailer（左拉）、`autoHideRefresh`、`exclusiveWithOtherRefresh`、`noMoreDataDisplayDuration`、`autoTriggerTimes`、GIF / Lottie / PAG / Rive 图标动画、`setAnimationImages:`、七种语言本地化与语言切换、完成 / 失败的本地化文字、`isCollectionViewAnimationBug`、RTL 翻转、链式写法、`cyl_scrollDistance` / `cyl_scrollDirection`、`beginRefreshingWithCompletionBlock:` 等回调。 | Features we have that it lacks: the trailer (pull left), `autoHideRefresh`, `exclusiveWithOtherRefresh`, `noMoreDataDisplayDuration`, `autoTriggerTimes`, GIF / Lottie / PAG / Rive icon animations, `setAnimationImages:`, seven languages with a language switch, localized done / failed texts, `isCollectionViewAnimationBug`, RTL flipping, chaining, `cyl_scrollDistance` / `cyl_scrollDirection`, completion callbacks such as `beginRefreshingWithCompletionBlock:`. |

| SmartRefreshControl 公开 API / public API | CYLRefresh API | 对齐 / Aligned |
| --- | --- | --- |
| `UISmartScrollMode`（Move / Stretch / Front） | `CYLRefreshScrollMode`（Move / Stretch / Front） | ✅ |
| `width` / `height` | `cyl_w` / `cyl_h`（UIView+CYLExtension） | ✅ |
| `triggerRate` | `triggerRate`（刷新头、返回式尾、trailer / header, back footer, trailer） | ✅ |
| `finishDuration` | `finishDuration` | ✅ |
| `durationFast` / `durationNormal` | `fastAnimationDuration` / `slowAnimationDuration` | ✅ |
| `scrollMode` | `scrollMode` | ✅ |
| `colorAccent` / `colorPrimary` | `colorAccent` / `colorPrimary` | ✅ |
| `isAttached` / `isExpanded` | `isAttached` / `isExpanded` | ✅ |
| `dragOffset` / `dragPercent` | `dragOffset` / `pullingPercent` | ✅ |
| `expandHeight` | `expandHeight` | ✅ |
| `target` / `scrollView` | `refreshingTarget` / `scrollView` | ✅ |
| `setUpComponent` | `prepare` | ✅ |
| `addObservers:` / `removeObservers:` | `addObservers` / `removeObservers` | ✅ |
| `scrollView:attached:` / `scrollView:detached:` | `didAttachToScrollView:` / `willDetachFromScrollView:` | ✅ |
| `scrollView:didChange:contentOffset:` / `…contentInset:` | `scrollViewContentOffsetDidChange:` / `scrollViewContentInsetDidChange:` | ✅ |
| `scrollView:didScroll:percent:drag:` | `didScrollWithOffset:percent:dragging:` | ✅ |
| `adjustFrameWithHeight:inset:expand:offset:` | `placeSubviews` + `scrollMode` | ✅ |
| `finalyContentInsetsFrom:` | `scrollViewOriginalInset` | ✅ |
| `+attach:` / `+attach:target:action:` / `-attach:` | `+attach:` / `+attach:target:action:` / `-attach:` | ✅ |
| `-addTarget:action:`（UIControl） | `-addTarget:action:` / `-removeTarget:action:`（可多个 / several） | ✅ |
| `UIRefreshStatus`（7 种 / 7 cases） | `CYLRefreshPhase`（8 种 / 8 cases） | ✅ |
| `RefreshBlock` / `refreshBlock` | `CYLRefreshComponentHandler` / `refreshingHandler`（另有 / also `refreshingBlock`） | ✅ |
| `keyForLastRefreshTime` / `nameForLastRefreshTime` | `lastUpdatedTimeKey` / `lastUpdatedTimeText` | ✅ |
| `lastRefreshTime`（可写 / writable） | `lastUpdatedTime`（可写 / writable） | ✅ |
| `lastRefreshTimeFormatter` | `lastUpdatedTimeFormatter` | ✅ |
| `isRefreshing` / `status` / `textLastRefreshTime` | `isRefreshing` / `phase` / `lastUpdatedTimeString` | ✅ |
| `inStatus:…` | `isInPhases:…` / `isInAnyPhase:` | ✅ |
| `beginRefresh` / `finishRefresh` / `finishRefreshWithSuccess:` | `beginRefreshing` / `endRefreshing` / `endRefreshingWithSuccess:` | ✅ |
| `performRefreshEvent` | `executeRefreshingCallback` | ✅ |
| `onStartAnimationWhenRealeasing` / `…WhenRefreshing` / `onStatus:changed:` | `phaseDidChangeFrom:to:`（Releasing / Refreshing） | ✅ |
| `onScrollingWithOffset:percent:drag:` | `didScrollWithOffset:percent:dragging:` | ✅ |
| `onRefreshFinished:` / `onRefreshFinishing:` | `refreshDidFinishWithSuccess:` / `finishingDurationWithSuccess:` | ✅ |
| `UISmartFooterStatus`（8 种 / 8 cases） | `CYLRefreshPhase`（含 / with `NoMoreData`） | ✅ |
| `UISmartFooterBlock` / `loadMoreBlock` | `refreshingHandler` / `refreshingBlock` | ✅ |
| `isAutoLoadMore` | `CYLRefreshAutoFooter.automaticallyRefresh` | ✅ |
| `isLoading` / `isNoMoreData` / `status` / `inStatus:` | `isRefreshing` / `isNoMoreData` / `phase` / `isInPhases:` | ✅ |
| `finishLoadMore` / `…WithNoMoreData` / `…WithSuccess:` | `endRefreshing` / `endRefreshingWithNoMoreData` / `endRefreshingWithSuccess:` | ✅ |
| `performLoadMoreEvent` / `resetNoMoreData` | `executeRefreshingCallback` / `resetNoMoreData` | ✅ |
| `onStartAnimationWhenLoading` / `…WhenRealeasing` / `onStatus:changed:` | `phaseDidChangeFrom:to:` | ✅ |
| `onScrollingWithOffset:…` / `onLoadMoreFinished:` / `onLoadMoreFinishing:` | `didScrollWithOffset:…` / `refreshDidFinishWithSuccess:` / `finishingDurationWithSuccess:` | ✅ |
| `UIRefreshClassicsHeader`：`spaceOfTitleAndTime` / `spaceOfLoadingAndText` | `CYLRefreshNormalHeader`：`titleTimeSpacing` / `labelLeftInset` | ✅ |
| `UIRefreshClassicsHeader`：`labelTitle` / `labelLastTime` / `viewArrow` / `viewLoading` | `stateLabel` / `lastUpdatedTimeLabel` / `arrowView` / `loadingView` | ✅ |
| `UIRefreshClassicsFooter`：`spaceOfLoadingAndText` / `labelTitle` / `viewArrow` / `viewLoading` | `CYLRefreshBackNormalFooter`：`labelLeftInset` / `stateLabel` / `arrowView` / `loadingView` | ✅ |
| `UIRefreshBezierCircleHeader` | — | TODO |
| `UIRefreshBezierRadarHeader` | — | TODO |
| `UIRefreshDeliveryHeader` | — | TODO |
| `UIRefreshDropBoxHeader` | — | TODO |
| `UIRefreshFlyHeader`（含 / with `FlyView`、`MountainView`） | — | TODO |
| `UIRefreshGameBattleCityHeader` | — | TODO |
| `UIRefreshGameHitBlockHeader` | — | TODO |
| `UIRefreshMaterialHeader` | — | TODO |
| `UIRefreshOriginalHeader`（`enableAutoRefresh`） | — | TODO |
| `UIRefreshPhoenixHeader` | — | TODO |
| `UIRefreshStoreHouseHeader`（`lineWidth`、`enableReverseFlash`、`enableFadeAnimation`、`newWithString:…`、`initLinesWith…`） | — | TODO |
| `UIRefreshTaurusHeader` | — | TODO |
| `UIRefreshWaveSwipeHeader` | — | TODO |
