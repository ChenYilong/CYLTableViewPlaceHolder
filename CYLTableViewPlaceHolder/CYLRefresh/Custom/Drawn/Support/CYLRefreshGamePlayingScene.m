//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Game/UIRefreshGamePlayingScene.m) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import "CYLRefreshGamePlayingScene.h"

@interface CYLRefreshGamePlayingScene ()

@property (nonatomic, strong) SKLabelNode *nodeTitle;

@end

@implementation CYLRefreshGamePlayingScene

- (void)setTitle:(NSString *)title {
    self.nodeTitle.text = title;
}

- (SKLabelNode *)nodeTitle {
    if (_nodeTitle == nil) {
        _nodeTitle = [SKLabelNode new];
        _nodeTitle.fontSize = 20;
        _nodeTitle.fontName = @"AvenirNext-Bold";
        _nodeTitle.text = self.title;
        [self addChild:_nodeTitle];
    }
    return _nodeTitle;
}

- (void)didMoveToView:(SKView *)view {
    [super didMoveToView:view];
//    [self setBackgroundColor:self.colorPrimary];
    [self setScaleMode:SKSceneScaleModeAspectFit];
    [self.nodeTitle setFontColor:self.colorAccent];
}


- (void)setColorPrimary:(UIColor *)colorPrimary {
    _colorPrimary = colorPrimary;
    [self setBackgroundColor:colorPrimary];
}

- (void)setColorAccent:(UIColor *)colorAccent {
    _colorAccent = colorAccent;
    [self.nodeTitle setFontColor:colorAccent];
}

//- (void)setSize:(CGSize)size {
//    [super setSize:size];
//    [self.nodeTitle setPosition:CGPointMake(size.width/2, size.height/2)];
//}

- (void)didChangeSize:(CGSize)oldSize {
    CGSize size = self.size;
    [super didChangeSize:oldSize];
    [self.nodeTitle setPosition:CGPointMake(size.width/2, size.height/2)];
}

- (void)reset {
    [self setTitle:@"None"];
}

- (void)start {
    [self setTitle:@"Loading..."];
}

- (void) gameWin {
    [self setTitle:@"Game Win"];
}

- (void)gameOver {
    [self setTitle:@"Game Over"];
}

- (void)moveHandle:(CGFloat)percent {
    
}

- (void)finishWithSuccess:(BOOL)success {
    if (success) {
        [self setTitle:@"Loading Finished"];
    } else {
        [self setTitle:@"Loading Failed!"];
    }
}

@end
