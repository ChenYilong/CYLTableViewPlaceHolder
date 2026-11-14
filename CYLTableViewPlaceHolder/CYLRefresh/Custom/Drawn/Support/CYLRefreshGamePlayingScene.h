//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Game/UIRefreshGamePlayingScene.h) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import <SpriteKit/SpriteKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CYLRefreshGamePlayingScene : SKScene

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) UIColor *colorAccent;
@property (nonatomic, strong) UIColor *colorPrimary;

- (void) reset;
- (void) start;

- (void) gameWin;
- (void) gameOver;
- (void) moveHandle: (CGFloat) percent;
- (void) finishWithSuccess: (BOOL) success;

@end

NS_ASSUME_NONNULL_END
