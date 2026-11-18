//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Game/UIRefreshGamePlayingScene.h (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.

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
