//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Header/UIRefreshStoreHouseHeader.h) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import "CYLRefreshDrawnHeader.h"


NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] Text drawn as line segments that gather while pulling and flash while refreshing (after CRefreshLayout StoreHouse).
 * [CN] 由线段组成的文字，下拉时聚拢，刷新时闪烁（参考 CRefreshLayout StoreHouse）。
 */
@interface CYLRefreshStoreHouseHeader : CYLRefreshDrawnHeader

/*!
 * [EN] Width of the line segments, in points. [CN] 线段宽度（点）。
 */
@property (nonatomic, assign) CGFloat lineWidth;
/*!
 * [EN] Flashes the segments in reverse order while refreshing. [CN] 刷新时按相反顺序闪烁线段。
 */
@property (nonatomic, assign) BOOL enableReverseFlash;
/*!
 * [EN] Fades the segments out when the refresh ends. [CN] 刷新结束时淡出线段。
 */
@property (nonatomic, assign) BOOL enableFadeAnimation;
/*!
 * [EN] A header that draws `string` (letters, digits and common punctuation). [CN] 绘制 `string`（字母、数字与常用标点）的刷新头。
 */
+ (instancetype) newWithString:(NSString*) string NS_SWIFT_NAME(init(string:));
/*!
 * [EN] The same, with the text scaled by `scale`. [CN] 同上，文字按 `scale` 缩放。
 */
+ (instancetype) newWithString:(NSString*) string scale:(CGFloat) scale NS_SWIFT_NAME(init(string:scale:));
/*!
 * [EN] The same, with `padding` points between letters. [CN] 同上，字母之间间隔 `padding` 点。
 */
+ (instancetype) newWithString:(NSString*) string scale:(CGFloat) scale padding:(CGFloat) padding NS_SWIFT_NAME(init(string:scale:padding:));
/*!
 * [EN] Replaces the drawn text with `string`. [CN] 把绘制的文字换成 `string`。
 */
- (void) initLinesWithString:(NSString*) string NS_SWIFT_NAME(setLines(string:));
/*!
 * [EN] The same, with the text scaled by `scale`. [CN] 同上，文字按 `scale` 缩放。
 */
- (void) initLinesWithString:(NSString*) string scale:(CGFloat) scale NS_SWIFT_NAME(setLines(string:scale:));
/*!
 * [EN] The same, with `padding` points between letters. [CN] 同上，字母之间间隔 `padding` 点。
 */
- (void) initLinesWithString:(NSString*) string scale:(CGFloat) scale padding:(CGFloat) padding NS_SWIFT_NAME(setLines(string:scale:padding:));
/*!
 * [EN] Draws custom segments: `array` holds point strings like `@"{24, 0}"`, two per segment (start, end).
 * [CN] 绘制自定义线段：`array` 为 `@"{24, 0}"` 形式的点字符串，每两个组成一条线段（起点、终点）。
 */
- (void) initLinesWithArray:(NSArray<NSString*>*)array NS_SWIFT_NAME(setLines(array:));
/*!
 * [EN] The same, with `padding` points around the drawing. [CN] 同上，图形四周留出 `padding` 点。
 */
- (void) initLinesWithArray:(NSArray<NSString*>*)array padding:(CGFloat) padding NS_SWIFT_NAME(setLines(array:padding:));
@end

NS_ASSUME_NONNULL_END
