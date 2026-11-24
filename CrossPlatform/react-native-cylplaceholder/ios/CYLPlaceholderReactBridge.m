#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTViewManager.h>

/**
 * [EN] The Objective-C half React Native's old architecture needs for the two Swift classes (the usual Swift pattern): the
 *      JavaScript names and the exported members. `CYLPlaceholderStack` is a view with the props `components`, `scenario`,
 *      `backgroundAction` and `restartToken`, the direct event `onAction` and the command `restartAnimation`; `CYLPlaceholderHUD`
 *      is a module with `call(method, arguments)` and the event "CYLPlaceholderHUDAction". Android's `CYLPlaceholderPackage` is
 *      the contract.
 * [CN] React Native 旧架构为两个 Swift 类所需的 Objective-C 一半（Swift 的惯用写法）：JavaScript 名称与导出成员。
 *      `CYLPlaceholderStack` 是带属性 `components`、`scenario`、`backgroundAction`、`restartToken`，直接事件 `onAction` 与命令
 *      `restartAnimation` 的视图；`CYLPlaceholderHUD` 是带 `call(method, arguments)` 与事件 “CYLPlaceholderHUDAction” 的模块。
 *      约定以 Android 的 `CYLPlaceholderPackage` 为准。
 */
@interface RCT_EXTERN_REMAP_MODULE(CYLPlaceholderStack, CYLPlaceholderStackManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(components, NSArray)
RCT_EXPORT_VIEW_PROPERTY(scenario, NSString)
RCT_EXPORT_VIEW_PROPERTY(backgroundAction, NSString)
RCT_EXPORT_VIEW_PROPERTY(restartToken, NSInteger)
RCT_EXPORT_VIEW_PROPERTY(onAction, RCTDirectEventBlock)

RCT_EXTERN_METHOD(restartAnimation:(nonnull NSNumber *)reactTag)

@end

@interface RCT_EXTERN_REMAP_MODULE(CYLPlaceholderHUD, CYLPlaceholderHUDModule, RCTEventEmitter)

RCT_EXTERN_METHOD(call:(NSString *)method arguments:(NSDictionary *)arguments)

@end
