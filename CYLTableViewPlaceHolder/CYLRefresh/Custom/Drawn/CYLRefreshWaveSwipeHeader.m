//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Header/UIRefreshWaveSwipeHeader.m) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import "CYLRefreshWaveSwipeHeader.h"

#import "CYLRefreshValueAnimator.h"

#define kCircleSize 40

#define kMaxArrowSize       2
#define kMaxArrowRadius     8

#define MAX_PROGRESS_ANGLE  0.8f
#define MAX_PROGRESS_ARC    0.8f

#define NUM_POINTS                  5
#define FULL_ROTATION               1080.0f
#define ANIMATION_DURATION          1.332f
#define COLOR_START_DELAY_OFFSET    0.75f
#define END_TRIM_START_DELAY_OFFSET 0.5f
#define START_TRIM_DURATION_OFFSET  0.5f


#define FAST_OUT_SLOW_VALUES @(0.0F), @(1.0E-4F), @(2.0E-4F), @(5.0E-4F), @(9.0E-4F), @(0.0014F), @(0.002F), @(0.0027F), @(0.0036F), @(0.0046F), @(0.0058F), @(0.0071F), @(0.0085F), @(0.0101F), @(0.0118F), @(0.0137F), @(0.0158F), @(0.018F), @(0.0205F), @(0.0231F), @(0.0259F), @(0.0289F), @(0.0321F), @(0.0355F), @(0.0391F), @(0.043F), @(0.0471F), @(0.0514F), @(0.056F), @(0.0608F), @(0.066F), @(0.0714F), @(0.0771F), @(0.083F), @(0.0893F), @(0.0959F), @(0.1029F), @(0.1101F), @(0.1177F), @(0.1257F), @(0.1339F), @(0.1426F), @(0.1516F), @(0.161F), @(0.1707F), @(0.1808F), @(0.1913F), @(0.2021F), @(0.2133F), @(0.2248F), @(0.2366F), @(0.2487F), @(0.2611F), @(0.2738F), @(0.2867F), @(0.2998F), @(0.3131F), @(0.3265F), @(0.34F), @(0.3536F), @(0.3673F), @(0.381F), @(0.3946F), @(0.4082F), @(0.4217F), @(0.4352F), @(0.4485F), @(0.4616F), @(0.4746F), @(0.4874F), @(0.5F), @(0.5124F), @(0.5246F), @(0.5365F), @(0.5482F), @(0.5597F), @(0.571F), @(0.582F), @(0.5928F), @(0.6033F), @(0.6136F), @(0.6237F), @(0.6335F), @(0.6431F), @(0.6525F), @(0.6616F), @(0.6706F), @(0.6793F), @(0.6878F), @(0.6961F), @(0.7043F), @(0.7122F), @(0.7199F), @(0.7275F), @(0.7349F), @(0.7421F), @(0.7491F), @(0.7559F), @(0.7626F), @(0.7692F), @(0.7756F), @(0.7818F), @(0.7879F), @(0.7938F), @(0.7996F), @(0.8053F), @(0.8108F), @(0.8162F), @(0.8215F), @(0.8266F), @(0.8317F), @(0.8366F), @(0.8414F), @(0.8461F), @(0.8507F), @(0.8551F), @(0.8595F), @(0.8638F), @(0.8679F), @(0.872F), @(0.876F), @(0.8798F), @(0.8836F), @(0.8873F), @(0.8909F), @(0.8945F), @(0.8979F), @(0.9013F), @(0.9046F), @(0.9078F), @(0.9109F), @(0.9139F), @(0.9169F), @(0.9198F), @(0.9227F), @(0.9254F), @(0.9281F), @(0.9307F), @(0.9333F), @(0.9358F), @(0.9382F), @(0.9406F), @(0.9429F), @(0.9452F), @(0.9474F), @(0.9495F), @(0.9516F), @(0.9536F), @(0.9556F), @(0.9575F), @(0.9594F), @(0.9612F), @(0.9629F), @(0.9646F), @(0.9663F), @(0.9679F), @(0.9695F), @(0.971F), @(0.9725F), @(0.9739F), @(0.9753F), @(0.9766F), @(0.9779F), @(0.9791F), @(0.9803F), @(0.9815F), @(0.9826F), @(0.9837F), @(0.9848F), @(0.9858F), @(0.9867F), @(0.9877F), @(0.9885F), @(0.9894F), @(0.9902F), @(0.991F), @(0.9917F), @(0.9924F), @(0.9931F), @(0.9937F), @(0.9944F), @(0.9949F), @(0.9955F), @(0.996F), @(0.9964F), @(0.9969F), @(0.9973F), @(0.9977F), @(0.998F), @(0.9984F), @(0.9986F), @(0.9989F), @(0.9991F), @(0.9993F), @(0.9995F), @(0.9997F), @(0.9998F), @(0.9999F), @(0.9999F), @(1.0F), @(1.0F)

/**
 * 落ちる前の回転の最大のAngle値
 */
#define MAX_PROGRESS_ROTATION_RATE MAX_PROGRESS_ANGLE

#define WAVE_FIRST          (0.1f)
#define WAVE_SECOND         (0.16f + WAVE_FIRST)
#define WAVE_THIRD          (0.5f + WAVE_FIRST)

/**
 * のDuration
 */
#define DROP_CIRCLE_ANIMATOR_DURATION       0.5f
#define DROP_VERTEX_ANIMATION_DURATION      0.5f
#define DROP_BOUNCE_ANIMATOR_DURATION       0.5f
#define DROP_REMOVE_ANIMATOR_DURATION       0.2f
/**
 * 波がくねくねしているDuration
 */
#define WAVE_ANIMATOR_DURATION              1.f
/**
 * 波の最大の高さ
 */
#define MAX_WAVE_HEIGHT                     0.2f
/**
 * 影の色 0x99000000
 */
#define SHADOW_COLOR [UIColor.blackColor colorWithAlphaComponent:0x99/255.0]

#define M_POW2(v) ((v)*(v))

/**
 * ベジェ曲線を引く際の座標
 * 左側の2つのアンカーポイントでいい感じに右側にも
 */
CGFloat BEGIN_PTS[6][2] = {
        //1
        {0.1655f, 0},           //ハンドル
        {0.4188f, -0.0109f},    //ハンドル
        {0.4606f, -0.0049f},    //アンカーポイント

        //2
        {0.4893f, 0.f},         //ハンドル
        {0.4893f, 0.f},         //ハンドル
        {0.5f, 0.f}             //アンカーポイント
};
CGFloat APPEAR_PTS[6][2] = {
        //1
        {0.1655f, 0.f},         //ハンドル
        {0.5237f, 0.0553f},     //ハンドル
        {0.4557f, 0.0936f},     //アンカーポイント

        //2
        {0.3908f, 0.1302f},     //ハンドル
        {0.4303f, 0.2173f},     //ハンドル
        {0.5f, 0.2173f}         //アンカーポイント
};
CGFloat EXPAND_PTS[6][2] = {
        //1
        {0.1655f, 0.f},         //ハンドル
        {0.5909f, 0.0000f},     //ハンドル
        {0.4557f, 0.1642f},     //アンカーポイント

        //2
        {0.3941f, 0.2061f},     //ハンドル
        {0.4303f, 0.2889f},     //ハンドル
        {0.5f, 0.2889f}         //アンカーポイント
};

@interface CYLRefreshWaveSwipeHeader ()<CYLRefreshValueAnimatorDelegate>

@property (nonatomic, strong) CAShapeLayer *waveLayer;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CAShapeLayer *arrowLayer;

@property (nonatomic, assign) CGPoint origin;

@property (nonatomic, strong) CYLRefreshValueAnimator *animatorDroping;
@property (nonatomic, strong) CYLRefreshValueAnimator *animatorFinishing;
@property (nonatomic, strong) CYLRefreshValueAnimator *animatorRefreshing;

@property (nonatomic, assign) CGFloat aniStartTrim;
@property (nonatomic, assign) CGFloat aniEndTrim;
@property (nonatomic, assign) CGFloat aniRotation;
@property (nonatomic, assign) CGFloat aniArrowScale;
@property (nonatomic, assign) CGFloat aniBeginStartTrim;
@property (nonatomic, assign) CGFloat aniBeginEndTrim;
@property (nonatomic, assign) CGFloat aniBeginRotation;

@property (nonatomic, assign) NSInteger aniRotationCount;

@property (nonatomic, copy) NSArray<NSNumber*> *aniFastOutSlowValues;
@property (nonatomic, copy) CYLRefreshAnimatorInterpolatorBlock dropBounceBlock;

@property (nonatomic, assign) CGFloat lastFirstBounds;
/**
 * 円のRadius = 100
 */
@property (nonatomic, assign) CGFloat dropCircleRadius;
/**
 * 円が落ちる最大の高さ
 */
@property (nonatomic, assign) CGFloat maxDropHeight;
/**
 * 落ちる円の高さが更新されたかどうか false
 */
@property (nonatomic, assign) BOOL dropHeightUpdated;
/**
 * を更新するための一時的な値の置き場
 */
@property (nonatomic, assign) CGFloat updateMaxDropHeight;
/**
 * 落ちてくる円についてくる三角形の一番上の頂点のAnimator
 */
@property (nonatomic, strong) CYLRefreshValueAnimator *animatorDropVertex;
/**
 * 落ちた円が横に伸びるときのAnimator
 */
@property (nonatomic, strong) CYLRefreshValueAnimator *animatorDropBounceVertical;
/**
 * 落ちた縁が縦に伸びるときのAnimator
 */
@property (nonatomic, strong) CYLRefreshValueAnimator *animatorDropBounceHorizontal;
/**
 * 落ちる円の中心座標のAnimator
 */
@property (nonatomic, strong) CYLRefreshValueAnimator *animatorDropCircle;
/**
 * 帰ってくる波ののAnimator
 */
@property (nonatomic, strong) CYLRefreshValueAnimator *animatorWaveReverse;

@end

@interface CYLRefreshDrawnHeader ()

@property (nonatomic, assign) CYLRefreshPhase status;

@end

@implementation CYLRefreshWaveSwipeHeader

/**
 * 初始化参数
 */
- (void)setUpComponent {
    [super setUpComponent];

    self.opaque = FALSE;
    self.height = kCircleSize * 3;
    self.finishDuration = 0.2;
    
    self.scrollMode = CYLRefreshScrollModeFront;
    self.colorAccent = [UIColor whiteColor];
    self.colorPrimary = [UIColor systemBlueColor];
    self.userInteractionEnabled = FALSE;
    
    CAShapeLayer *waveLayer = [CAShapeLayer layer];
    waveLayer.fillColor = [self.colorPrimary CGColor];
    waveLayer.shadowColor = [[UIColor blackColor] CGColor];
    waveLayer.shadowOffset = CGSizeMake(0, 1);
    waveLayer.shadowOpacity = 0.3;
    waveLayer.shadowRadius = 1.5;
    [waveLayer setFillRule:kCAFillRuleEvenOdd];
    [self.layer addSublayer:waveLayer];
    [self setWaveLayer:waveLayer];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillColor = [self.colorPrimary CGColor];
    shapeLayer.shadowColor = [[UIColor blackColor] CGColor];
    shapeLayer.shadowOffset = CGSizeMake(0, 1);
    shapeLayer.shadowOpacity = 0.3;
    shapeLayer.shadowRadius = 1.5;
    [shapeLayer setFillRule:kCAFillRuleEvenOdd];
    [self.layer addSublayer:shapeLayer];
    [self setShapeLayer:shapeLayer];

    CAShapeLayer *arrowLayer = [CAShapeLayer layer];
    arrowLayer.strokeColor = [[[UIColor darkGrayColor] colorWithAlphaComponent:0.5] CGColor];
    arrowLayer.lineWidth = 0.5;
    arrowLayer.fillColor = [self.colorAccent CGColor];
    [self.shapeLayer addSublayer:arrowLayer];
    [self setArrowLayer:arrowLayer];

    CAShapeLayer *highlightLayer = [CAShapeLayer layer];
    highlightLayer.fillColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.2] CGColor];
    [highlightLayer setFillRule:kCAFillRuleNonZero];
    [self.shapeLayer addSublayer:highlightLayer];
    
    self.aniFastOutSlowValues = @[FAST_OUT_SLOW_VALUES];
    self.dropCircleRadius = kMaxArrowRadius;// + kMaxArrowSize / 2;
    
    self.dropBounceBlock = ^CGFloat(CGFloat v) {
        //y = -19 * (x - 0.125)^2 + 1.3     (0 <= x < 0.25)
        //y = -6.5 * (x - 0.625)^2 + 1.1    (0.5 <= x < 0.75)
        //y = 0                             (0.25 <= x < 0.5 || 0.75 <= x <=1)
        
        if (v < 0.25f) {
            return -38.4f * (CGFloat) M_POW2(v - 0.125) + 0.6f;
        } else if (v >= 0.5 && v < 0.75) {
            return -19.2f * (CGFloat) M_POW2(v - 0.625) + 0.3f;
        } else {
            return 0;
        }
    };
}

- (void)setColorAccent:(UIColor *)colorAccent {
    [super setColorAccent:colorAccent];
    [self.arrowLayer setFillColor:[colorAccent CGColor]];
}

- (void)setColorPrimary:(UIColor *)colorPrimary {
    [super setColorPrimary:colorPrimary];
    [self.shapeLayer setFillColor:[colorPrimary CGColor]];
    [self.waveLayer setFillColor:[colorPrimary CGColor]];
}

- (void)buildArrow:(const CGPoint *)origin p:(CGFloat)percent b:(CGFloat) begin e:(CGFloat) end r:(CGFloat) rotate s:(CGFloat) scale{
    
    CGMutablePathRef arrowPath = CGPathCreateMutable();
    
    [self buildArrowPath:arrowPath origin:origin p:percent b:begin e:end r:rotate s:scale];
    
    _arrowLayer.path = arrowPath;
    CGPathRelease(arrowPath);
}

/**
 * @param origin 圆心点
 * @param percent 下拉百分比
 * @param begin 箭头开始角度 0～1 代表 0～360
 * @param end 箭头结束角度 0～1 代表 0～360
 * @param rotate 箭头旋转角度 0～1 代表 0～360
 * @param scale 箭头缩放比例 （小于 0.3 时不绘制箭头）
 */
- (void)buildArrowPath:(CGMutablePathRef) path origin:(const CGPoint *)origin p:(CGFloat)percent b:(CGFloat) begin e:(CGFloat) end r:(CGFloat) rotate s:(CGFloat) scale {
    
    if (percent > 0) {
        // Add the arrow shape
        CGFloat arrowSize = kMaxArrowSize;
        CGFloat arrowRadius = kMaxArrowRadius;
        CGFloat arrowBigRadius = arrowRadius + (arrowSize / 2);
        CGFloat arrowSmallRadius = arrowRadius - (arrowSize / 2);
        CGFloat angleEnd = MAX(begin, end);
        CGFloat angleStart = MIN(end, begin);
        CGFloat anglePercent = MIN(1, MAX(0, angleEnd - angleStart));
        CGFloat angleAdjust = ((1 - anglePercent) * 2 * M_PI) - M_PI_2;
        CGFloat rotateAdjust = angleEnd*2*M_PI;
        
        CGAffineTransform tf = CGAffineTransformIdentity;
        tf = CGAffineTransformTranslate(tf, origin->x, origin->y);
        tf = CGAffineTransformRotate(tf, rotateAdjust + rotate * 2 * M_PI);
        tf = CGAffineTransformTranslate(tf, -origin->x, -origin->y);
        CGPathAddArc(path, &tf, origin->x, origin->y, arrowBigRadius, angleAdjust, 3 * M_PI_2, NO);
        
        if (scale > 0.3) {
            CGFloat centerX = origin->x;
            CGFloat centerY = origin->y - arrowBigRadius +  arrowSize / 2;
            
            tf = CGAffineTransformTranslate(tf, centerX, centerY);
            tf = CGAffineTransformScale(tf, scale, scale);
            tf = CGAffineTransformTranslate(tf, -centerX, -centerY);
            
            CGPathAddLineToPoint(path, &tf, origin->x, origin->y - arrowBigRadius - arrowSize);
            CGPathAddLineToPoint(path, &tf, origin->x + (2 * arrowSize), origin->y - arrowBigRadius + (arrowSize / 2));
            CGPathAddLineToPoint(path, &tf, origin->x, origin->y - arrowBigRadius + (2 * arrowSize));
            CGPathAddLineToPoint(path, &tf, origin->x, origin->y - arrowBigRadius + arrowSize);
            
            tf = CGAffineTransformTranslate(tf, centerX, centerY);
            tf = CGAffineTransformScale(tf, 1.f / scale, 1.f / scale);
            tf = CGAffineTransformTranslate(tf, -centerX, -centerY);
        }
        
        CGPathAddArc(path, &tf, origin->x, origin->y, arrowSmallRadius, 3 * M_PI_2, angleAdjust, YES);
        CGPathCloseSubpath(path);
    }
}

- (void)wavePhase:(CGFloat) width first:(CGFloat) move1 {
    CGMutablePathRef path = CGPathCreateMutable();
    
    if (move1 > 0.008) {
        //円を描画し始める前の引っ張ったら膨れる波の部分の描画
        CGPathMoveToPoint(path, nil, 0, 0);
        //左半分の描画
        CGPathAddCurveToPoint(path, nil,
                width * BEGIN_PTS[0][0], BEGIN_PTS[0][1],
                width * BEGIN_PTS[1][0], width * (BEGIN_PTS[1][1] + move1),
                width * BEGIN_PTS[2][0], width * (BEGIN_PTS[2][1] + move1));
        CGPathAddCurveToPoint(path, nil,
                width * BEGIN_PTS[3][0], width * (BEGIN_PTS[3][1] + move1),
                width * BEGIN_PTS[4][0], width * (BEGIN_PTS[4][1] + move1),
                width * BEGIN_PTS[5][0], width * (BEGIN_PTS[5][1] + move1));
        //右半分の描画
        CGPathAddCurveToPoint(path, nil,
                width - width * BEGIN_PTS[4][0], width * (BEGIN_PTS[4][1] + move1),
                width - width * BEGIN_PTS[3][0], width * (BEGIN_PTS[3][1] + move1),
                width - width * BEGIN_PTS[2][0], width * (BEGIN_PTS[2][1] + move1));
        CGPathAddCurveToPoint(path, nil,
                width - width * BEGIN_PTS[1][0], width * (BEGIN_PTS[1][1] + move1),
                width - width * BEGIN_PTS[0][0], BEGIN_PTS[0][1],
                width, 0);
    }
    
    [self.waveLayer setPath:path];
    [self.waveLayer setShadowPath:path];
    CGPathRelease(path);
}
- (void)wavePhase:(CGFloat) width first:(CGFloat) move1 second:(CGFloat) move2 {
    CGMutablePathRef path = CGPathCreateMutable();
    
    //円を描画し始める前の引っ張ったら膨れる波の部分の描画
    CGPathMoveToPoint(path, nil, 0, 0);

    //左半分の描画
    CGPathAddCurveToPoint(path, nil,width * APPEAR_PTS[0][0], width * APPEAR_PTS[0][1],
            width * MIN(BEGIN_PTS[1][0] + move2, APPEAR_PTS[1][0]),
            width * MAX(BEGIN_PTS[1][1] + move1 - move2, APPEAR_PTS[1][1]),
            width * MAX(BEGIN_PTS[2][0] - move2, APPEAR_PTS[2][0]),
            width * MAX(BEGIN_PTS[2][1] + move1 - move2, APPEAR_PTS[2][1]));
    
    CGPathAddCurveToPoint(path, nil,
            width * MAX(BEGIN_PTS[3][0] - move2, APPEAR_PTS[3][0]),
            width * MIN(BEGIN_PTS[3][1] + move1 + move2, APPEAR_PTS[3][1]),
            width * MAX(BEGIN_PTS[4][0] - move2, APPEAR_PTS[4][0]),
            width * MIN(BEGIN_PTS[4][1] + move1 + move2, APPEAR_PTS[4][1]),
            width * APPEAR_PTS[5][0],
            width * MIN(BEGIN_PTS[0][1] + move1 + move2, APPEAR_PTS[5][1]));
    //右半分の描画
    CGPathAddCurveToPoint(path, nil,
            width - width * MAX(BEGIN_PTS[4][0] - move2, APPEAR_PTS[4][0]),
            width * MIN(BEGIN_PTS[4][1] + move1 + move2, APPEAR_PTS[4][1]),
            width - width * MAX(BEGIN_PTS[3][0] - move2, APPEAR_PTS[3][0]),
            width * MIN(BEGIN_PTS[3][1] + move1 + move2, APPEAR_PTS[3][1]),
            width - width * MAX(BEGIN_PTS[2][0] - move2, APPEAR_PTS[2][0]),
            width * MAX(BEGIN_PTS[2][1] + move1 - move2, APPEAR_PTS[2][1]));
    CGPathAddCurveToPoint(path, nil,
            width - width * MIN(BEGIN_PTS[1][0] + move2, APPEAR_PTS[1][0]),
            width * MAX(BEGIN_PTS[1][1] + move1 - move2, APPEAR_PTS[1][1]),
            width - width * APPEAR_PTS[0][0], width * APPEAR_PTS[0][1], width, 0);
    
    self.origin = CGPointMake(_origin.x, width * MIN(BEGIN_PTS[3][1] + move1 + move2, APPEAR_PTS[3][1])
                              + _dropCircleRadius);
    
    [self.waveLayer setPath:path];
    [self.waveLayer setShadowPath:path];
    CGPathRelease(path);
}
- (void)wavePhase:(CGFloat) width first:(CGFloat) move1 second:(CGFloat) move2 final:(CGFloat) move3 {
    CGMutablePathRef path = CGPathCreateMutable();
    
    //円を描画し始める前の引っ張ったら膨れる波の部分の描画
    CGPathMoveToPoint(path, nil, 0, 0);

    //左半分の描画
    CGPathAddCurveToPoint(path, nil,
      width * EXPAND_PTS[0][0],
      width * EXPAND_PTS[0][1],
      width * MIN( MIN(BEGIN_PTS[1][0] + move2, APPEAR_PTS[1][0]) + move3, EXPAND_PTS[1][0]),
      width * MAX( MAX(BEGIN_PTS[1][1] + move1 - move2, APPEAR_PTS[1][1]) - move3, EXPAND_PTS[1][1]),
      width * MAX(BEGIN_PTS[2][0] - move2, EXPAND_PTS[2][0]),
      width * MIN( MAX(BEGIN_PTS[2][1] + move1 - move2, APPEAR_PTS[2][1]) + move3,EXPAND_PTS[2][1]));
    
    CGPathAddCurveToPoint(path, nil,
      width * MIN( MAX(BEGIN_PTS[3][0] - move2, APPEAR_PTS[3][0]) + move3, EXPAND_PTS[3][0]),
      width * MIN( MIN(BEGIN_PTS[3][1] + move1 + move2, APPEAR_PTS[3][1]) + move3, EXPAND_PTS[3][1]),
      width * MAX(BEGIN_PTS[4][0] - move2, EXPAND_PTS[4][0]),
      width * MIN( MIN(BEGIN_PTS[4][1] + move1 + move2, APPEAR_PTS[4][1]) + move3, EXPAND_PTS[4][1]),
      width * EXPAND_PTS[5][0],
      width * MIN( MIN(BEGIN_PTS[0][1] + move1 + move2, APPEAR_PTS[5][1]) + move3, EXPAND_PTS[5][1]));

    //右半分の描画
    CGPathAddCurveToPoint(path, nil,
      width - width * MAX(BEGIN_PTS[4][0] - move2, EXPAND_PTS[4][0]),
      width * MIN( MIN(BEGIN_PTS[4][1] + move1 + move2, APPEAR_PTS[4][1]) + move3, EXPAND_PTS[4][1]),
      width - width * MIN( MAX(BEGIN_PTS[3][0] - move2, APPEAR_PTS[3][0]) + move3, EXPAND_PTS[3][0]),
      width * MIN( MIN(BEGIN_PTS[3][1] + move1 + move2, APPEAR_PTS[3][1]) + move3, EXPAND_PTS[3][1]),
      width - width * MAX(BEGIN_PTS[2][0] - move2, EXPAND_PTS[2][0]),
      width * MIN( MAX(BEGIN_PTS[2][1] + move1 - move2, APPEAR_PTS[2][1]) + move3, EXPAND_PTS[2][1]));
    
    CGPathAddCurveToPoint(path, nil,
      width - width * MIN( MIN(BEGIN_PTS[1][0] + move2, APPEAR_PTS[1][0]) + move3, EXPAND_PTS[1][0]),
      width * MAX( MAX(BEGIN_PTS[1][1] + move1 - move2, APPEAR_PTS[1][1]) - move3, EXPAND_PTS[1][1]),
      width - width * EXPAND_PTS[0][0], width * EXPAND_PTS[0][1],
      width, 0);
    
    self.origin = CGPointMake(_origin.x, width * MIN( MIN(BEGIN_PTS[3][1] + move1 + move2, APPEAR_PTS[3][1]) + move3, EXPAND_PTS[3][1]) + _dropCircleRadius);
    
    [self.waveLayer setPath:path];
    [self.waveLayer setShadowPath:path];
    CGPathRelease(path);
}

#pragma -mark Override

- (void)scrollView:(UIScrollView *)scrollView attached:(BOOL)attach {
    [super scrollView:scrollView attached:attach];
    [self setMaxDropHeight:self.width];
}

- (void)onScrollingWithOffset:(CGFloat)offset percent:(CGFloat)percent drag:(BOOL)isDragging {

    if (self.status == CYLRefreshPhaseRefreshing
        || self.status == CYLRefreshPhaseReleasing
        || self.status == CYLRefreshPhaseFinishing) {
        return;
    }
    
    if (isDragging) {
        CGFloat width = self.width;
        
        const CGFloat seed = offset / width;
        const CGFloat firstBounds = seed * (5.f - 2 * seed) / 3.5f;
        const CGFloat secondBounds = firstBounds - WAVE_FIRST;
        const CGFloat finalBounds = (firstBounds - WAVE_SECOND) / 5;
        
        if (firstBounds < WAVE_FIRST) {
            // draw a wave and not draw a circle
            [self wavePhase:width first:firstBounds];
        } else if (firstBounds < WAVE_SECOND) {
            // draw a circle with a wave
            [self wavePhase:width first:firstBounds second:secondBounds];
        } else /*if (firstBounds < WAVE_THIRD)*/ {
            // draw a circle with expanding a wave
            [self wavePhase:width first:firstBounds second:secondBounds final:finalBounds];
//        } else {
//            // stop to draw a wave and drop a circle
//            onDropPhase();
        }

        CGPoint origin = CGPointMake(floor(width / 2), self.origin.y);
        
        const CGFloat dragPercent = MIN(1.f, percent);
        const CGFloat adjustedPercent = MAX(dragPercent - .4, 0) * 5 / 3;

        // 0f...2f
        const CGFloat tensionSlingshotPercent = (percent > 3.f) ? 2.f : (percent > 1.f) ? percent - 1.f : 0;
        const CGFloat tensionPercent = (4.f - tensionSlingshotPercent) * tensionSlingshotPercent / 8.f;

        if (percent < 1.f) {
            [self setAniStartTrim:0];
            [self setAniArrowScale:MIN(1, adjustedPercent)];
            [self setAniEndTrim:MIN(adjustedPercent * .8f, MAX_PROGRESS_ROTATION_RATE)];
        }
        
        const CGFloat rotation = (-0.25f + .4f * adjustedPercent + tensionPercent * 2) * .5f;
        
        [self setOrigin:origin];
        [self setAniRotation:rotation];
        [self setLastFirstBounds:firstBounds];
        [self buildArrow:&origin p:percent b:_aniStartTrim e:_aniEndTrim r:rotation s:_aniArrowScale];
    } else if (_lastFirstBounds > 0) {
        [self startAnimationWaveReverse:_lastFirstBounds];
        [self setAniRotation:0];
        [self setAniEndTrim:0];
        [self setAniStartTrim:0];
        [self setAniArrowScale:0];
        [self setLastFirstBounds:0];
    }
}

- (void)onStartAnimationWhenRealeasing {
    if (self.dragOffset == 0) {
        //手动调用 beginRefresh 时定位小球的原始落点
        [self setOrigin:CGPointMake(floor(self.width / 2), self.width * 500 / 1440)];
    }
    
    [self setLastFirstBounds:0];
    [self startAnimationDroping];
    [self startAnimationWaveReverse:0.1f];
}

- (void)onStartAnimationWhenRefreshing {
    [self setAniRotationCount:0];
    if (_aniStartTrim != _aniEndTrim) {
        [self storeOriginals];
        [self startAnimatorFinishing];
    } else {
        [self resetOriginals];
        [self startAnimatorRefreshing];
    }
}

- (void)onRefreshFinished:(BOOL)success {
    if (self.animatorFinishing) {
        [self.animatorFinishing stop];
    }
    if (self.animatorRefreshing) {
        [self.animatorRefreshing stop];
    }
    
    CGPoint origin = self.origin;
    CGMutablePathRef toPath = CGPathCreateMutable();
    CGPathAddRect(toPath, nil, CGRectMake(origin.x-1, origin.y-1, 2, 2));
    id function = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CABasicAnimation *pathMorph = [CABasicAnimation animationWithKeyPath:@"path"];
    pathMorph.duration = self.finishDuration;
    pathMorph.fillMode = kCAFillModeForwards;
    pathMorph.removedOnCompletion = YES;
    pathMorph.toValue = (__bridge id)toPath;
    pathMorph.fromValue = (__bridge id)self.shapeLayer.path;
    pathMorph.timingFunction = function;
    [self.shapeLayer addAnimation:pathMorph forKey:nil];
    
    CABasicAnimation *shadowPathMorph = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
    shadowPathMorph.duration = self.finishDuration;
    shadowPathMorph.fillMode = kCAFillModeForwards;
    shadowPathMorph.removedOnCompletion = YES;
    shadowPathMorph.toValue = (__bridge id)toPath;
    shadowPathMorph.fromValue = (__bridge id)self.shapeLayer.shadowPath;
    shadowPathMorph.timingFunction = function;
    [self.shapeLayer addAnimation:shadowPathMorph forKey:nil];
    CGPathRelease(toPath);

    [self.arrowLayer setPath:nil];
    [self.shapeLayer setPath:nil];
    [self.shapeLayer setShadowPath:nil];
}

#pragma -mark Animation

- (void)resetAnimator {
    [self setAnimatorDropVertex:[CYLRefreshValueAnimator newWithFrom:0 to:0]];
    [self setAnimatorDropBounceVertical:[CYLRefreshValueAnimator newWithFrom:0 to:0]];
    [self setAnimatorDropBounceHorizontal:[CYLRefreshValueAnimator newWithFrom:0 to:0]];
    [self setAnimatorDropCircle:[CYLRefreshValueAnimator newWithFrom:-1000 to:-1000]];
}

/**
 * @param h 波が始まる高さ
 */
- (void)startAnimationWaveReverse:(CGFloat) h {
    CGFloat width = self.width;
    h = MIN(h, MAX_WAVE_HEIGHT) * width;

    CYLRefreshValueAnimator *animator = [CYLRefreshValueAnimator newWithFrom:h to:0];
    [animator setDuration:WAVE_ANIMATOR_DURATION];
    [animator setDelegate:self];
    [animator setTarget:self selector:@selector(onAnimationWaveReverse:)];
    [animator setInterpolator:AnimatorInterpolatorBounce];
    [animator start];
    [self setAnimatorWaveReverse:animator];
    
    [self.arrowLayer setPath:nil];
}

- (void)startAnimationDroping {
    self.maxDropHeight = self.width;
    
    CYLRefreshValueAnimator* animator = [CYLRefreshValueAnimator new];
    [animator setDuration:DROP_VERTEX_ANIMATION_DURATION+DROP_BOUNCE_ANIMATOR_DURATION*1.25f];
    [animator setDelegate:self];
    [animator setTarget:self selector:@selector(onAnimationDroping:)];
    [animator start];
    [self setAnimatorDroping:animator];

    animator = [CYLRefreshValueAnimator new];
    [animator setFrom:self.width * 500 / 1440 to:self.maxDropHeight];
    [animator setDuration:DROP_CIRCLE_ANIMATOR_DURATION];
    [animator setTarget:self selector:@selector(onAnimationDroping:)];
    [animator setInterpolator:AnimatorInterpolatorAccelerateDecelerate];
    [animator start];
    [self setAnimatorDropCircle:animator];
    
    animator = [CYLRefreshValueAnimator new];
    [animator setFrom:self.origin.y to:0];
    [animator setDuration:DROP_VERTEX_ANIMATION_DURATION];
    [animator setInterpolator:AnimatorInterpolatorDecelerate];
    [animator start];
    [self setAnimatorDropVertex:animator];
    
    animator = [CYLRefreshValueAnimator new];
    [animator setFrom:0 to:1];
    [animator setDuration:DROP_BOUNCE_ANIMATOR_DURATION];
    [animator setBeginTime:DROP_VERTEX_ANIMATION_DURATION];
    [animator setInterpolatorBlock:_dropBounceBlock];
    [animator start];
    [self setAnimatorDropBounceVertical:animator];
    
    animator = [CYLRefreshValueAnimator new];
    [animator setFrom:0 to:1];
    [animator setDuration:DROP_BOUNCE_ANIMATOR_DURATION];
    [animator setBeginTime:DROP_VERTEX_ANIMATION_DURATION+DROP_BOUNCE_ANIMATOR_DURATION*0.25f];
    [animator setInterpolatorBlock:_dropBounceBlock];
    [animator start];
    [self setAnimatorDropBounceHorizontal:animator];
}

- (void)onAnimationWaveReverse:(CYLRefreshValueAnimator*) animator {
    if (self.scrollView.isDragging &&
        (self.status != CYLRefreshPhaseRefreshing
        && self.status != CYLRefreshPhaseReleasing)) {
        //拖拽可以打断动画
        [animator stop];
        return;
    }
    
    CGFloat width = self.width;
    CGFloat h = animator.value;

    CGMutablePathRef path = CGPathCreateMutable();
    
    if (h > 0.008) {
        CGPathMoveToPoint(path, nil, 0, 0);
        CGPathAddQuadCurveToPoint(path, nil, width * 0.25f, 0, width * 0.333f, h * 0.5f);
        CGPathAddQuadCurveToPoint(path, nil, width * 0.50f, h * 1.4f, width * 0.666f, h * 0.5f);
        CGPathAddQuadCurveToPoint(path, nil, width * 0.75f, 0, width, 0);
    }
    
    [self.waveLayer setPath:path];
    [self.waveLayer setShadowPath:path];
    CGPathRelease(path);
}

- (void)onAnimationDroping:(CYLRefreshValueAnimator*) animator {
    if (animator == self.animatorDropCircle) {
        _origin = CGPointMake(_origin.x, animator.value);
    } else if (animator == self.animatorDroping) {
        CGFloat circleCenterY = _origin.y;
        CGFloat circleCenterX = _origin.x;
        
        CGFloat vertical = _animatorDropBounceVertical.value;
        CGFloat horizontal = _animatorDropBounceHorizontal.value;
        CGFloat vertex = _animatorDropVertex.value;
        CGFloat _dropCircleRadius = self.dropCircleRadius * 3;
        
        CGMutablePathRef pathDropTangent = CGPathCreateMutable();
        
        if (vertex > 0) {
            CGFloat arcos = acos(_dropCircleRadius / (_dropCircleRadius + vertex));
            CGFloat start = M_PI + (M_PI_2 -  arcos);
            CGFloat close = arcos - M_PI_2;
            CGPathMoveToPoint(pathDropTangent, nil, circleCenterX, circleCenterY - _dropCircleRadius - vertex);
            CGPathAddArc(pathDropTangent, nil, circleCenterX, circleCenterY, _dropCircleRadius, start, close, TRUE);
        } else {
            CGRect dropRect = CGRectMake(0, 0, 0, 0);
            dropRect.size.width = 2 * _dropCircleRadius * (1 + vertical);
            dropRect.size.height = 2 * _dropCircleRadius * (1 + horizontal);
            dropRect.origin.x = circleCenterX - dropRect.size.width / 2;
            dropRect.origin.y = circleCenterY - dropRect.size.height / 2;

            CGPathAddEllipseInRect(pathDropTangent, nil, dropRect);
        }
        
        [self.shapeLayer setPath:pathDropTangent];
        [self.shapeLayer setShadowPath:pathDropTangent];
        CGPathRelease(pathDropTangent);
    }
}

- (void)onAnimationEnd:(CYLRefreshValueAnimator *)animator {
    if (animator == self.animatorRefreshing) {
        self.animatorRefreshing = nil;
    } else if (animator == self.animatorWaveReverse) {
        self.animatorWaveReverse = nil;
    } else if (animator == self.animatorDropCircle) {
        self.animatorDropCircle = nil;
    } else if (animator == self.animatorDroping) {
        self.animatorDroping = nil;
    } else if (animator == self.animatorFinishing) {
        [self setAnimatorFinishing:nil];
        if (self.isRefreshing) {
            [self storeOriginals];
            [self setAniStartTrim:_aniEndTrim];
            [self startAnimatorRefreshing];
        }
    }
}

/**
 * 动画执行
 */
- (void)onAnimationRefreshing:(CYLRefreshValueAnimator*) animator {
    const CGFloat interpolatedTime = animator.percent;
    const CGFloat startingTrim = _aniBeginStartTrim;
    const CGFloat startingEndTrim = _aniBeginEndTrim;
    const CGFloat startingRotation = _aniBeginRotation;
    const CGFloat minProgressArc = [self getMinProgressArc];

//    updateRingColor(interpolatedTime, ring);

    // Moving the start trim only occurs in the first 50% of a
    // single ring animation
    if (interpolatedTime <= START_TRIM_DURATION_OFFSET) {
        // scale the interpolatedTime so that the full
        // transformation from 0 - 1 takes place in the
        // remaining time
        const CGFloat scaledTime = (interpolatedTime)
                / (1.0f - START_TRIM_DURATION_OFFSET);
        const CGFloat percent = [self getFastOutSlowValue:scaledTime];
        _aniStartTrim = (startingTrim + ((MAX_PROGRESS_ARC - minProgressArc) * percent));
    }

    // Moving the end trim starts after 50% of a single ring
    // animation completes
    if (interpolatedTime > END_TRIM_START_DELAY_OFFSET) {
        // scale the interpolatedTime so that the full
        // transformation from 0 - 1 takes place in the
        // remaining time
        const CGFloat minArc = MAX_PROGRESS_ARC - minProgressArc;
        const CGFloat scaledTime = (interpolatedTime - START_TRIM_DURATION_OFFSET)
                / (1.0f - START_TRIM_DURATION_OFFSET);
        const CGFloat percent = [self getFastOutSlowValue:scaledTime];
        _aniEndTrim = (startingEndTrim + (minArc * percent));
    }
    
    _aniRotation = startingRotation + (0.25f * interpolatedTime);
    
    CGFloat groupRotation = ((FULL_ROTATION / NUM_POINTS) * interpolatedTime) + (FULL_ROTATION * (_aniRotationCount / NUM_POINTS));
    
    CGPoint origin = self.origin;
    CGFloat rotate = _aniRotation + groupRotation / 360;
    CGMutablePathRef arrowPath = CGPathCreateMutable();
    [self buildArrowPath:arrowPath origin:&origin p:1 b:_aniStartTrim e:_aniEndTrim r:_aniRotation=rotate s:0];
    [self.arrowLayer setPath:arrowPath];
    CGPathRelease(arrowPath);
}

/**
 * 动画执行
 */
- (void)onAnimationFinishing:(CYLRefreshValueAnimator*) animator {
    // shrink back down and complete a full rotation before
    // starting other circles
    // Rotation goes between [0..1].
    
    const CGFloat interpolatedTime = animator.percent;
    const CGFloat minProgressArc = [self getMinProgressArc];
    const CGFloat targetRotation = floor(_aniBeginRotation / MAX_PROGRESS_ARC) + 1.f;
    const CGFloat startTrim = _aniBeginStartTrim + (_aniBeginEndTrim - minProgressArc - _aniBeginStartTrim) * interpolatedTime;
    const CGFloat rotation = _aniBeginRotation + ((targetRotation - _aniBeginRotation) * interpolatedTime);
    
    [self setAniStartTrim:startTrim];
    [self setAniEndTrim:_aniBeginEndTrim];
    [self setAniRotation:rotation];

    CGPoint origin = self.origin;
    CGMutablePathRef arrowPath = CGPathCreateMutable();
    [self buildArrowPath:arrowPath origin:&origin p:1 b:startTrim e:_aniBeginEndTrim r:rotation s:_aniArrowScale];
    [self.arrowLayer setPath:arrowPath];
    CGPathRelease(arrowPath);
}

- (void)onAnimationRepeat:(CYLRefreshValueAnimator *)animator {
    if (animator == self.animatorRefreshing) {
        [self storeOriginals];
        [self setAniStartTrim:_aniEndTrim];
        [self setAniRotationCount:(_aniRotationCount + 1) % NUM_POINTS];
    }
}

- (void)startAnimatorRefreshing {
    CYLRefreshValueAnimator *animator = [CYLRefreshValueAnimator new];
    [animator setTarget:self selector:@selector(onAnimationRefreshing:)];
    [animator setDelegate:self];
    [animator setDuration:ANIMATION_DURATION];
    [animator setRepeatCount:INFINITY];
    [animator setRepeatMode:AnimatorRepeatModeRestart];
    [animator start];
    [self setAnimatorRefreshing:animator];
}

- (void)startAnimatorFinishing {
    CYLRefreshValueAnimator *animator = [CYLRefreshValueAnimator new];
    [animator setTarget:self selector:@selector(onAnimationFinishing:)];
    [animator setDelegate:self];
    [animator setDuration:ANIMATION_DURATION/2];
    [animator start];
    [self setAnimatorFinishing:animator];
}

- (CGFloat)getMinProgressArc {
    return (kMaxArrowSize / (2 * M_PI * kMaxArrowRadius)) * M_PI / 180;
}

- (CGFloat)getFastOutSlowValue:(CGFloat) paramFloat {
    if (paramFloat >= 1.0F) {
        return 1.0F;
    }
    if (paramFloat <= 0.0F) {
        return 0.0F;
    }
    NSArray<NSNumber*>* values = self.aniFastOutSlowValues;
    NSUInteger length = values.count;
    CGFloat stepSize = (1.0F / (length - 1));
    NSInteger i = MIN((NSInteger)((length - 1) * paramFloat), length - 2);
    paramFloat = (paramFloat - i * stepSize) / stepSize;
    return values[i].floatValue + (values[(i + 1)].floatValue - values[i].floatValue) * paramFloat;
}

- (void)storeOriginals{
    _aniBeginEndTrim = _aniEndTrim;
    _aniBeginStartTrim = _aniStartTrim;
    _aniBeginRotation = _aniRotation;
}

- (void)resetOriginals{
    _aniEndTrim = 0;
    _aniStartTrim = 0;
    _aniRotation = 0;
    [self storeOriginals];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}


@end
