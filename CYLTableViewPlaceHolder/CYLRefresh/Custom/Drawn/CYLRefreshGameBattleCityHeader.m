//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Header/UIRefreshGameBattleCityHeader.m) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import "CYLRefreshGameBattleCityHeader.h"

#import "CYLRefreshGamePlayingScene.h"

#define NAME_PLAYER    @"player"
#define NAME_TANK      @"tank"
#define NAME_BULLET    @"bullet"
#define NAME_WORLD     @"world"

#define MASK_PLAYER     0x1
#define MASK_TANK       0x2
#define MASK_BULLET     0x4
#define MASK_WORLD      0x8

#define TANK_ROW_NUM            3           //轨道数量
#define TANK_BARREL_RATIO       (1.0/3)     //炮管尺寸所在tank尺寸的比率
#define BULLET_NUM_SPACING      200         //默认子弹之间空隙间距
#define TANK_NUM_SPACING        40          //默认敌方坦克之间间距

@interface BattleCityScene : CYLRefreshGamePlayingScene<SKPhysicsContactDelegate>

@property (nonatomic, strong) SKShapeNode *nodePlayer;
@property (nonatomic, strong) UIBezierPath *pathPlayer;
@property (nonatomic, strong) SKShapeNode *nodeBullet;
@property (nonatomic, strong) UIBezierPath *pathBullet;
@property (nonatomic, strong) SKShapeNode *nodeEnemy;
@property (nonatomic, strong) UIBezierPath *pathEnemy;

@property (nonatomic, assign) CGFloat spaceEnemy;
@property (nonatomic, assign) CGFloat spaceBullet;

@property (nonatomic, assign) BOOL isGameRunning;

@end

@interface CYLRefreshGameHeader (CYLRefreshGameBattleCityHeader)

- (CYLRefreshGamePlayingScene*) newPlayingScene;

@end

@implementation CYLRefreshGameBattleCityHeader

- (CYLRefreshGamePlayingScene *)newPlayingScene {
    return [BattleCityScene new];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

@implementation BattleCityScene

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initize];
    }
    return self;
}

- (void)initize {
    [self setName:@"BattleCityScene"];
    [self setScaleMode:SKSceneScaleModeFill];
    [self.physicsWorld setGravity:CGVectorMake(0, 0)];
    [self.physicsWorld setContactDelegate:self];
    
    [self setPathPlayer:[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 20, 20)]];
    
    [self setNodePlayer:[SKShapeNode new]];
    [self.nodePlayer setName:NAME_PLAYER];
    [self addChild: self.nodePlayer];
}

- (void)setColorAccent:(UIColor *)colorAccent {
    [super setColorAccent:colorAccent];
    [self.nodePlayer setFillColor:colorAccent];
}

- (void)didChangeSize:(CGSize)oldSize {
    [super didChangeSize:oldSize];
    
    CGSize size = self.size;
    
    id body = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    [self setPhysicsBody:body];
    [self.physicsBody setCategoryBitMask:MASK_WORLD];
    [self.physicsBody setFriction:0.0];
    [self.physicsBody setRestitution:0.1];
    [self.physicsBody setDynamic:YES];
    
    CGFloat sizeTank = size.height / TANK_ROW_NUM;
    CGFloat halfTank = sizeTank / 2;
    CGFloat sizeBarrel = sizeTank * TANK_BARREL_RATIO;
    CGFloat paddingBarrel = (sizeTank - sizeBarrel)/2;
    
    [self setPathPlayer:[UIBezierPath new]];
    [self.pathPlayer moveToPoint:CGPointMake(halfTank, halfTank)];
    [self.pathPlayer addLineToPoint:CGPointMake( halfTank, -halfTank)];
    [self.pathPlayer addLineToPoint:CGPointMake(-halfTank, -halfTank)];
    [self.pathPlayer addLineToPoint:CGPointMake(-halfTank, -halfTank + paddingBarrel)];
    [self.pathPlayer addLineToPoint:CGPointMake(-halfTank - sizeBarrel, -halfTank + paddingBarrel)];
    [self.pathPlayer addLineToPoint:CGPointMake(-halfTank - sizeBarrel, -halfTank + paddingBarrel+ sizeBarrel)];
    [self.pathPlayer addLineToPoint:CGPointMake(-halfTank, -halfTank + paddingBarrel+ sizeBarrel)];
    [self.pathPlayer addLineToPoint:CGPointMake(-halfTank, halfTank)];
    [self.pathPlayer closePath];
    
    [self.nodePlayer setPath:self.pathPlayer.CGPath];
    [self.nodePlayer setPosition:CGPointMake(size.width-halfTank, size.height - halfTank)];
    [self.nodePlayer setPhysicsBody:[SKPhysicsBody bodyWithPolygonFromPath:self.pathPlayer.CGPath]];
    [self.nodePlayer.physicsBody setCategoryBitMask:MASK_PLAYER];
    [self.nodePlayer.physicsBody setAllowsRotation:FALSE];
    
    CGRect rectBullet = CGRectMake(-sizeBarrel/2, -sizeBarrel/2, sizeBarrel, sizeBarrel);
    [self setPathBullet:[UIBezierPath bezierPathWithOvalInRect:rectBullet]];
    
    [self setPathEnemy:[UIBezierPath new]];
    [self.pathEnemy moveToPoint:CGPointMake(-halfTank, halfTank)];
    [self.pathEnemy addLineToPoint:CGPointMake(-halfTank, -halfTank)];
    [self.pathEnemy addLineToPoint:CGPointMake(halfTank-paddingBarrel, -halfTank)];
    [self.pathEnemy addLineToPoint:CGPointMake(halfTank-paddingBarrel, -halfTank + paddingBarrel)];
    [self.pathEnemy addLineToPoint:CGPointMake(halfTank, -halfTank + paddingBarrel)];
    [self.pathEnemy addLineToPoint:CGPointMake(halfTank, halfTank - paddingBarrel)];
    [self.pathEnemy addLineToPoint:CGPointMake(halfTank-paddingBarrel, halfTank - paddingBarrel)];
    [self.pathEnemy addLineToPoint:CGPointMake(halfTank-paddingBarrel, halfTank)];
    [self.pathEnemy closePath];
    
}

- (void)update:(NSTimeInterval)currentTime {
    [super update:currentTime];
    
    if (!self.isGameRunning) {
        return;
    }
    
    CGSize sizeScene = self.size;
    CGFloat sizeTank = sizeScene.height / TANK_ROW_NUM;
    CGFloat sizeBarrel = sizeTank * TANK_BARREL_RATIO;
    
    if (self.nodeEnemy == nil || self.nodeEnemy.position.x > self.spaceEnemy + sizeTank) {
        [self setNodeEnemy:[SKShapeNode node]];
        [self.nodeEnemy setName:NAME_TANK];
        [self.nodeEnemy setFillColor:self.colorAccent];
        [self.nodeEnemy setPosition:CGPointMake(sizeTank/2 + 5, sizeTank*(0.5 + arc4random()%TANK_ROW_NUM))];
        [self.nodeEnemy setPath:self.pathEnemy.CGPath];
        [self.nodeEnemy setPhysicsBody:[SKPhysicsBody bodyWithPolygonFromPath:self.pathEnemy.CGPath]];
        [self.nodeEnemy.physicsBody setFriction:0];
        [self.nodeEnemy.physicsBody setLinearDamping:0];
        [self.nodeEnemy.physicsBody setAllowsRotation:FALSE];
        [self.nodeEnemy.physicsBody setUsesPreciseCollisionDetection:TRUE];
        [self.nodeEnemy.physicsBody setCategoryBitMask:MASK_TANK];
        [self.nodeEnemy.physicsBody setContactTestBitMask:MASK_WORLD|MASK_PLAYER];
        [self addChild:self.nodeEnemy];
        [self.nodeEnemy.physicsBody applyImpulse:CGVectorMake(2, 0)];
    }
    
    if (self.nodeBullet.position.x < sizeScene.width - sizeTank - sizeBarrel - self.spaceBullet) {
        
        CGPoint pt = self.nodePlayer.position;
        
        [self setNodeBullet:[SKShapeNode node]];
        [self.nodeBullet setName:NAME_BULLET];
        [self.nodeBullet setFillColor:self.colorAccent];
        [self.nodeBullet setPosition:CGPointMake(pt.x - sizeTank - sizeBarrel/3, pt.y)];
        [self.nodeBullet setPath:self.pathBullet.CGPath];
        [self.nodeBullet setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:sizeBarrel/2]];
        [self.nodeBullet.physicsBody setFriction:0];
        [self.nodeBullet.physicsBody setLinearDamping:0];
        [self.nodeBullet.physicsBody setAllowsRotation:FALSE];
        [self.nodeBullet.physicsBody setUsesPreciseCollisionDetection:TRUE];
        [self.nodeBullet.physicsBody setCategoryBitMask:MASK_BULLET];
        [self.nodeBullet.physicsBody setContactTestBitMask:MASK_WORLD|MASK_TANK];
        [self addChild:self.nodeBullet];
        [self.nodeBullet.physicsBody applyImpulse:CGVectorMake(-1, 0)];
    }
}

- (void)reset {
    [self setNodeEnemy:nil];
    [self setNodeBullet:nil];
    [self setSpaceEnemy:TANK_NUM_SPACING];
    [self setSpaceBullet:BULLET_NUM_SPACING];
    
    CGSize sizeScene = self.size;
    CGFloat sizeTank = sizeScene.height / TANK_ROW_NUM;
    CGFloat halfTank = sizeTank / 2;
    [self.nodePlayer setPosition:CGPointMake(sizeScene.width-halfTank, sizeScene.height - halfTank)];
    
    [self enumerateChildNodesWithName:NAME_TANK usingBlock:^(SKNode* node, BOOL* stop) {
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:NAME_BULLET usingBlock:^(SKNode* node, BOOL* stop) {
        [node removeFromParent];
    }];
}

- (void)start {
    [self setIsGameRunning:TRUE];
}

- (void)moveHandle:(CGFloat)percent {
    CGSize sizeScene = self.size;
    CGFloat sizeTank = sizeScene.height / TANK_ROW_NUM;
//    CGFloat halfTank = sizeTank / 2;
//    CGFloat sizeBarrel = sizeTank * TANK_BARREL_RATIO;
//    CGFloat paddingBarrel = (sizeTank - sizeBarrel)/2;
    
    CGPoint old = self.nodePlayer.position;
    CGFloat y = (sizeScene.height - sizeTank)*(1-percent) + sizeTank/2;
    CGPoint new = CGPointMake(old.x, y);
    [self.nodePlayer setPosition:new];
}

- (void)didEndContact:(SKPhysicsContact *)contact {
    
    if (contact.bodyB.node == nil || contact.bodyA.node == nil) {
        
        return;
    }
    NSArray<SKNode*>* array = @[contact.bodyA.node, contact.bodyB.node];
    for (SKNode* node in array) {
        if (node == self.nodeBullet) {
            self.nodeBullet = nil;
        } else if (node == self.nodeEnemy) {
            self.nodeEnemy = nil;
        } else if (node == self.nodePlayer) {
            [self gameOver];
        }
        if (node != self && node != self.nodePlayer) {
            [node removeFromParent];
        }
    }
//
//    if (self.isGameWin) {
//        [self gameWin];
//    }
}

- (void)gameWin {
    [super gameWin];
    [self setIsGameRunning:FALSE];
}

- (void)gameOver {
    [super gameOver];
    [self setIsGameRunning:FALSE];
}

- (BOOL)isGameWin {
//    __block NSUInteger count = 0;
//    [self enumerateChildNodesWithName:NAME_BLOCK usingBlock:^(SKNode* node, BOOL* stop) {
//        count = count + 1;
//    }];
//    return count == 0;
    return FALSE;
}


@end
