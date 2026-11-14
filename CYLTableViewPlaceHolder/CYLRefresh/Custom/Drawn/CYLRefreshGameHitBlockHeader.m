//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Header/UIRefreshGameHitBlockHeader.m) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import "CYLRefreshGameHitBlockHeader.h"

#import "CYLRefreshGamePlayingScene.h"

#define NAME_BALL      @"ball"
#define NAME_BLOCK     @"block"
#define NAME_LINE      @"line"
#define NAME_PADDLE    @"paddle"

#define MASK_BALL       0x1
#define MASK_LINE       0x2
#define MASK_BLOCK      0x4
#define MASK_PADDLE     0x8

@interface HitBlockScene : CYLRefreshGamePlayingScene<SKPhysicsContactDelegate>

@property (nonatomic, strong) SKNode *nodeEndLine;
@property (nonatomic, strong) SKSpriteNode *nodeBall;
@property (nonatomic, strong) SKSpriteNode *nodePaddle;

@end

@interface CYLRefreshGameHeader (CYLRefreshGameHitBlockHeader)

- (CYLRefreshGamePlayingScene*) newPlayingScene;

@end

@implementation CYLRefreshGameHitBlockHeader

- (CYLRefreshGamePlayingScene *)newPlayingScene {
    return [HitBlockScene new];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

@implementation HitBlockScene

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initize];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"dealloc-%@", self.name);
}

- (void)initize {
    [self setName:@"HitBlockScene"];
    [self setScaleMode:SKSceneScaleModeFill];
    [self.physicsWorld setGravity:CGVectorMake(0, 0)];
    [self.physicsWorld setContactDelegate:self];
    
    [self setNodeEndLine:[SKNode new]];
    [self.nodeEndLine setName:NAME_LINE];
    [self addChild:self.nodeEndLine];
    
    CGSize sizePaddle = CGSizeMake(5, 30);
    [self setNodePaddle:[SKSpriteNode new]];
    [self.nodePaddle setSize:sizePaddle];
    [self.nodePaddle setName:NAME_PADDLE];
    [self.nodePaddle setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:sizePaddle]];
    [self.nodePaddle.physicsBody setDynamic:FALSE];
    [self.nodePaddle.physicsBody setFriction:0];
    [self.nodePaddle.physicsBody setRestitution:1];
    [self.nodePaddle.physicsBody setCategoryBitMask:MASK_PADDLE];
    [self addChild:self.nodePaddle];
    
    CGSize sizeBall = CGSizeMake(8, 8);
    [self setNodeBall:[SKSpriteNode new]];
    [self.nodeBall setSize:sizeBall];
    [self.nodeBall setName:NAME_BALL];
    [self.nodeBall setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:sizeBall.width/2]];
    [self.nodeBall.physicsBody setFriction:0];
    [self.nodeBall.physicsBody setRestitution:1];
    [self.nodeBall.physicsBody setLinearDamping:0];
    [self.nodeBall.physicsBody setAllowsRotation:FALSE];
    [self.nodeBall.physicsBody setUsesPreciseCollisionDetection:TRUE];
    [self.nodeBall.physicsBody setCategoryBitMask:MASK_BALL];
    [self.nodeBall.physicsBody setContactTestBitMask:MASK_LINE|MASK_BLOCK];
    [self addChild:self.nodeBall];
    
//    SKSpriteNode* node = nil;
//    
//    NSLog(@"node = %@", NSStringFromCGSize(node.size));
}

- (void)setColorAccent:(UIColor *)colorAccent {
    [super setColorAccent:colorAccent];
    [self.nodeBall setColor:colorAccent];
    [self.nodePaddle setColor:colorAccent];
}

- (void)didChangeSize:(CGSize)oldSize {
    [super didChangeSize:oldSize];
    
    CGSize size = self.size;
    
    id body = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    [self setPhysicsBody:body];
    [self.physicsBody setFriction:0.0];
    [self.physicsBody setRestitution:0.1];
    [self.physicsBody setDynamic:YES];
    
    CGPoint from = CGPointMake(size.width - 1, 0);
    CGPoint to = CGPointMake(size.width - 1, size.height);
    id lineBody = [SKPhysicsBody bodyWithEdgeFromPoint:from toPoint:to];
    [self.nodeEndLine setPhysicsBody:lineBody];
    [self.nodePaddle.physicsBody setCategoryBitMask:MASK_LINE];
    
    CGFloat yPaddle = size.height - self.nodePaddle.size.height / 2;
    [self.nodePaddle setPosition:CGPointMake(size.width-30, yPaddle)];
}

- (void)reset {
    CGSize size = self.size;
    CGSize sizePaddle = self.nodePaddle.size;
    [self.nodeBall setHidden:FALSE];
    [self.nodeBall setPosition:CGPointMake(size.width-30-sizePaddle.width, size.height/2)];
    [self.nodeBall.physicsBody setVelocity:CGVectorMake(0, 0)];
    
    CGFloat yPaddle = size.height - sizePaddle.height / 2;
    [self.nodePaddle setPosition:CGPointMake(size.width-30, yPaddle)];
    
    for (id node = [self childNodeWithName:NAME_BLOCK]; node != nil; ) {
        [node removeFromParent];
        node = [self childNodeWithName:NAME_BLOCK];
    }
    
    CGSize sizeBlock = CGSizeMake(5, (self.size.height-4)/5);

    for (int i = 0; i < 3; i++) {
        UIColor* color = [self.colorAccent colorWithAlphaComponent:1-i*0.2];
        for (int j = 0; j < 5; j++) {
            SKPhysicsBody* blockBody = [SKPhysicsBody bodyWithRectangleOfSize:sizeBlock];
            [blockBody setFriction:0];
            [blockBody setRestitution:1];
            [blockBody setDynamic:FALSE];
            [blockBody setAllowsRotation:FALSE];
            [blockBody setCategoryBitMask:MASK_BLOCK];
            
            CGFloat y = j*(sizeBlock.height+1)+sizeBlock.height/2;
            SKSpriteNode* node = [SKSpriteNode new];
            [node setColor:color];
            [node setSize:sizeBlock];
            [node setName:NAME_BLOCK];
            [node setPhysicsBody:blockBody];
            [node setPosition:CGPointMake(20+i*6, y)];
            [self addChild:node];
        }
    }
}

- (void)start {
    CGFloat y = (30.0 - (arc4random() % 60)) / 100;
    NSLog(@"start.y = %@", @(y));
    [self.nodeBall.physicsBody applyImpulse:CGVectorMake(-0.5, y)];
}

- (void)moveHandle:(CGFloat)percent {
    CGSize sizeScene = self.size;
    CGSize sizePaddle = self.nodePaddle.size;
    CGPoint old = self.nodePaddle.position;
    CGFloat y = (sizeScene.height - sizePaddle.height)*(1-percent) + sizePaddle.height/2;
    CGPoint new = CGPointMake(old.x, y);
    [self.nodePaddle setPosition:new];
}

//- (void)didBeginContact:(SKPhysicsContact *)contact {
//    NSLog(@"didBeginContact=%@", contact);
//}

- (void)didEndContact:(SKPhysicsContact *)contact {
    
    NSArray<SKNode*>* array = @[contact.bodyA.node, contact.bodyB.node];
    for (SKNode* node in array) {
        if (node == self.nodeEndLine) {
            [self gameOver];
        } else if (node.physicsBody.categoryBitMask == MASK_BLOCK) {
            [node removeFromParent];
        }
    }
    
    if (self.isGameWin) {
        [self gameWin];
    }
}

- (void)gameWin {
    [super gameWin];
    [self.nodeBall.physicsBody setVelocity:CGVectorMake(0, 0)];
    [self.nodeBall setHidden:YES];
}

- (void)gameOver {
    [super gameOver];
    [self.nodeBall.physicsBody setVelocity:CGVectorMake(0, 0)];
    [self.nodeBall setHidden:YES];
}

- (BOOL)isGameWin {
    __block NSUInteger count = 0;
    [self enumerateChildNodesWithName:NAME_BLOCK usingBlock:^(SKNode* node, BOOL* stop) {
        count = count + 1;
    }];
    return count == 0;
}


@end
