//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Header/UIRefreshFlyHeader.h) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import "CYLRefreshDrawnHeader.h"


NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] A paper plane over mountains that flies off while refreshing (after FlyRefresh). Always open: the scene stays above the list and refreshing does not push the content.
 * [CN] 山上的纸飞机，刷新时飞走（参考 FlyRefresh）。常态展开：场景一直显示在列表上方，刷新时不推动内容。
 */
@interface CYLRefreshFlyHeader : CYLRefreshDrawnHeader

@end

NS_ASSUME_NONNULL_END
