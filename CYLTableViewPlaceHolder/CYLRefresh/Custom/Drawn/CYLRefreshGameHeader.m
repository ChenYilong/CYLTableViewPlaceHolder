//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Game/UIRefreshGameHeader.m) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import <SpriteKit/SpriteKit.h>

#import "CYLRefreshGameHeader.h"
#import "CYLRefreshGameStartScene.h"
#import "CYLRefreshGamePlayingScene.h"

@interface CYLRefreshGameHeader ()

@property (nonatomic, assign) BOOL requestFinish;
/// [EN] The result to finish with once the user stops dragging. [CN] 用户停止拖动后用来结束的结果。
@property (nonatomic, assign) BOOL cyl_pendingSuccess;
@property (nonatomic, strong) SKView *gameView;
@property (nonatomic, strong) CYLRefreshGameStartScene *sceneStart;
@property (nonatomic, strong) CYLRefreshGamePlayingScene *scenePlaying;

- (CYLRefreshGamePlayingScene*) newPlayingScene;

@end

@implementation CYLRefreshGameHeader

- (void)setUpComponent {
    [super setUpComponent];
    
    [self setHeight:100];
    [self setColorAccent:UIColor.whiteColor];
    [self setColorPrimary:UIColor.darkGrayColor];
    [self setScrollMode:CYLRefreshScrollModeMove];
}

- (SKView *)gameView {
    if (_gameView == nil) {
        _gameView = [SKView new];
    }
    return _gameView;
}

- (CYLRefreshGameStartScene *)sceneStart {
    if (_sceneStart == nil) {
        _sceneStart = [CYLRefreshGameStartScene new];
        _sceneStart.colorAccent = self.colorAccent;
        _sceneStart.colorPrimary = self.colorPrimary;
    }
    return _sceneStart;
}

- (CYLRefreshGamePlayingScene *)scenePlaying {
    if (_scenePlaying == nil) {
        _scenePlaying = [self newPlayingScene];
        _scenePlaying.colorAccent = self.colorAccent;
        _scenePlaying.colorPrimary = self.colorPrimary;
    }
    return _scenePlaying;
}

- (void)setFrame:(CGRect)frame {
    if (self.isAttached && self.frame.size.width != frame.size.width) {
        [super setFrame:frame];
        [self.sceneStart setSize:self.bounds.size];
        [self.scenePlaying setSize:self.bounds.size];
        [self.gameView setFrame:self.bounds];
    } else {
        [super setFrame:frame];
    }
}

- (void)setColorPrimary:(UIColor *)colorPrimary {
    [super setColorPrimary:colorPrimary];
    [self.scenePlaying setColorPrimary:colorPrimary];
    [self.sceneStart setColorPrimary:colorPrimary];
}

- (void)setColorAccent:(UIColor *)colorAccent {
    [super setColorAccent:colorAccent];
    [self.scenePlaying setColorAccent:colorAccent];
    [self.sceneStart setColorAccent:colorAccent];
}


- (CYLRefreshGamePlayingScene *)newPlayingScene {
    return [CYLRefreshGamePlayingScene new];
}

- (void)scrollView:(UIScrollView *)scrollView attached:(BOOL)attach {
    [super scrollView:scrollView attached:attach];
    [self.sceneStart setSize:self.bounds.size];
    [self.scenePlaying setSize:self.bounds.size];
    [self.gameView setFrame:self.bounds];
    [self.gameView presentScene:self.sceneStart];
    [self addSubview:self.gameView];
}

- (void)scrollView:(UIScrollView *)scrollView didScroll:(CGFloat)offset percent:(CGFloat)percent drag:(BOOL)isDragging {
    [super scrollView:scrollView didScroll:offset percent:percent drag:isDragging];
    if (self.isRefreshing) {
        if (!isDragging && self.requestFinish) {
            [self setRequestFinish:FALSE];
            [super finishRefreshWithSuccess:self.cyl_pendingSuccess];
        }
    }
}


//- (void)scrollView:(UIScrollView *)scrollView didChange:(CYLRefreshPhase)old status:(CYLRefreshPhase)status {
- (void)onStatus:(CYLRefreshPhase)old changed:(CYLRefreshPhase)status {
//    [super scrollView:scrollView didChange:old status:status];
    [super onStatus:old changed:status];
    if (status == CYLRefreshPhaseRefreshing) {
        [self setScrollMode:CYLRefreshScrollModeFront];
    } else if (status == CYLRefreshPhaseFinishing) {
        [self setScrollMode:CYLRefreshScrollModeMove];
        SKTransition* transition = [SKTransition doorsCloseVerticalWithDuration:0.4];
        [self.gameView presentScene:self.sceneStart transition:transition];
    } else if (status == CYLRefreshPhaseIdle) {
        [self setNeedsLayout];
    }
}

- (void)onScrollingWithOffset:(CGFloat)offset percent:(CGFloat)percent drag:(BOOL)isDragging {
    if (isDragging) {
        [self.scenePlaying moveHandle:MIN(1,MAX((percent-1),0))];
    }
}

- (void)finishRefreshWithSuccess:(BOOL)success {
    [self.scenePlaying finishWithSuccess: success];
    if (self.scrollView.isDragging) {
        [self setCyl_pendingSuccess:success];
        [self setRequestFinish:TRUE];
    } else {
        [super finishRefreshWithSuccess:success];
    }
}

- (void)onStartAnimationWhenRefreshing {
    SKTransition* transition = [SKTransition doorsOpenVerticalWithDuration:0.4];
    [self.scenePlaying reset];
    [self.scenePlaying start];
    [self.scenePlaying setTitle:@"Refreshing..."];
    [self.gameView presentScene:self.scenePlaying transition:transition];
}

@end
