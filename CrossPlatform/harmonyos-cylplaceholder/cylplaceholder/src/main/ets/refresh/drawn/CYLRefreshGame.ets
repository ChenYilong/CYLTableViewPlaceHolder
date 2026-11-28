// CYLRefreshGame: the HarmonyOS counterparts of iOS Custom/Drawn/CYLRefreshGameHeader.h, CYLRefreshGameHitBlockHeader.h,
// CYLRefreshGameBattleCityHeader.h and Support/CYLRefreshGameStartScene.h, CYLRefreshGamePlayingScene.h (after
// FunGameRefresh). The SpriteKit scenes are canvas scenes: the start scene while pulling, the playing scene while
// refreshing (opened and closed with SKTransition's vertical doors). The SpriteKit physics is replaced by box
// overlap tests with the same contacts and outcomes. The player is moved, as on iOS, by dragging the list further
// while refreshing (`moveHandle`), and also by touching the header: the vertical position of the finger.
import { CYLRefreshScrollViewModel } from '../CYLRefreshComponent';
import { CYLRefreshComponentAction, CYLRefreshPhase, CYLRefreshScrollMode } from '../CYLRefreshConst';
import { CYLRefreshDrawnColor } from './CYLRefreshDrawnSupport';
import { CYLRefreshDrawnHeaderModel, CYLRefreshDrawnTouch } from './CYLRefreshDrawnHeader';

const GAME_FONT: string = 'bold 20vp sans-serif';
const GAME_FONT_DETAIL: string = 'bold 17vp sans-serif';
const DOORS_DURATION: number = 400;

/** The scene shown while pulling (iOS `CYLRefreshGameStartScene`). */
export class CYLRefreshGameStartScene {
  /** The background color (`colorAccent`). */
  colorAccent: string = '#ffffff';
  /** The texts' and frame's color (`colorPrimary`). */
  colorPrimary: string = '#555555';

  /** Draws the scene in a `w` x `h` frame. */
  drawInContext(ctx: CanvasRenderingContext2D, w: number, h: number): void {
    ctx.fillStyle = this.colorAccent;
    ctx.fillRect(0, 0, w, h);
    ctx.strokeStyle = this.colorPrimary;
    ctx.lineWidth = 1;
    ctx.strokeRect(0.5, 0.5, w - 1, h - 1);
    ctx.fillStyle = this.colorPrimary;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'alphabetic';
    ctx.font = GAME_FONT;
    ctx.fillText('Pull to Break Out!', w / 2, h / 2 - 5);
    ctx.font = GAME_FONT_DETAIL;
    ctx.fillText('Scroll to move handle', w / 2, h / 2 + 15);
  }
}

/** The scene played while refreshing (iOS `CYLRefreshGamePlayingScene`); the games subclass it. */
export class CYLRefreshGamePlayingScene {
  /** The centered title (`title`). */
  title: string = '';
  /** The sprites' and title's color (`colorAccent`). */
  colorAccent: string = '#ffffff';
  /** The background (`colorPrimary`). */
  colorPrimary: string = '#555555';
  /** The scene size (SKScene size), set by the header. */
  width: number = 0;
  height: number = 100;

  /** Back to the start positions (`-reset`). */
  reset(): void {
    this.title = 'None';
  }

  /** The game starts (`-start`). */
  start(): void {
    this.title = 'Loading...';
  }

  /** The player won (`-gameWin`). */
  gameWin(): void {
    this.title = 'Game Win';
  }

  /** The player lost (`-gameOver`). */
  gameOver(): void {
    this.title = 'Game Over';
  }

  /** Moves the player: 0 at the top, 1 at the bottom (`-moveHandle:`). */
  moveHandle(percent: number): void {
  }

  /** The refresh ended (`-finishWithSuccess:`). */
  finishWithSuccess(success: boolean): void {
    this.title = success ? 'Loading Finished' : 'Loading Failed!';
  }

  /** Advances the game by `dt` seconds (SKScene update and physics). */
  update(dt: number): void {
  }

  /** Draws the background, the sprites and the title. */
  drawInContext(ctx: CanvasRenderingContext2D): void {
    ctx.fillStyle = this.colorPrimary;
    ctx.fillRect(0, 0, this.width, this.height);
    this.drawSprites(ctx);
    ctx.fillStyle = this.colorAccent;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.font = GAME_FONT;
    ctx.fillText(this.title, this.width / 2, this.height / 2);
  }

  protected drawSprites(ctx: CanvasRenderingContext2D): void {
  }
}

/** A sprite box: center and size. */
export class CYLRefreshGameNode {
  x: number;
  y: number;
  w: number;
  h: number;
  vx: number = 0;
  vy: number = 0;
  alpha: number = 1;

  constructor(x: number, y: number, w: number, h: number) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  overlaps(o: CYLRefreshGameNode): boolean {
    return Math.abs(this.x - o.x) <= (this.w + o.w) / 2 && Math.abs(this.y - o.y) <= (this.h + o.h) / 2;
  }
}

/** The brick breaker (iOS HitBlockScene): 3 x 5 blocks on the left, the paddle on the right, the end line behind it. */
export class CYLRefreshGameHitBlockScene extends CYLRefreshGamePlayingScene {
  /** The ball's speed, in vp/s (SpriteKit's impulse on the 8 pt ball). */
  static ballSpeed: number = 220;
  /** The random vertical share of the start impulse; tests replace it. */
  static random: () => number = () => (30 - Math.floor(Math.random() * 60)) / 100;
  paddle: CYLRefreshGameNode = new CYLRefreshGameNode(0, 15, 5, 30);
  ball: CYLRefreshGameNode = new CYLRefreshGameNode(0, 50, 8, 8);
  ballHidden: boolean = false;
  blocks: CYLRefreshGameNode[] = [];

  reset(): void {
    super.reset();
    const w = this.width;
    const h = this.height;
    this.ballHidden = false;
    this.ball = new CYLRefreshGameNode(w - 30 - this.paddle.w, h / 2, 8, 8);
    this.paddle = new CYLRefreshGameNode(w - 30, this.paddle.h / 2, 5, 30);
    this.blocks = [];
    const bh = (h - 4) / 5;
    for (let i = 0; i < 3; i++) {
      for (let j = 0; j < 5; j++) {
        const block = new CYLRefreshGameNode(20 + i * 6, j * (bh + 1) + bh / 2, 5, bh);
        block.alpha = 1 - i * 0.2;
        this.blocks.push(block);
      }
    }
  }

  start(): void {
    super.start();
    const y = CYLRefreshGameHitBlockScene.random();
    this.ball.vx = -CYLRefreshGameHitBlockScene.ballSpeed;
    this.ball.vy = y / 0.5 * CYLRefreshGameHitBlockScene.ballSpeed;
  }

  moveHandle(percent: number): void {
    const p = Math.min(1, Math.max(0, percent));
    this.paddle.y = (this.height - this.paddle.h) * p + this.paddle.h / 2;
  }

  gameWin(): void {
    super.gameWin();
    this.stopBall();
  }

  gameOver(): void {
    super.gameOver();
    this.stopBall();
  }

  private stopBall(): void {
    this.ball.vx = 0;
    this.ball.vy = 0;
    this.ballHidden = true;
  }

  update(dt: number): void {
    const b = this.ball;
    if (this.ballHidden || (b.vx === 0 && b.vy === 0)) {
      return;
    }
    const r = b.w / 2;
    b.x += b.vx * dt;
    b.y += b.vy * dt;
    // The edge loop of the scene.
    if (b.y - r < 0) {
      b.y = r;
      b.vy = Math.abs(b.vy);
    }
    if (b.y + r > this.height) {
      b.y = this.height - r;
      b.vy = -Math.abs(b.vy);
    }
    if (b.x - r < 0) {
      b.x = r;
      b.vx = Math.abs(b.vx);
    }
    // The paddle bounces the ball back.
    const p = this.paddle;
    if (b.vx > 0 && b.x + r >= p.x - p.w / 2 && b.x < p.x && Math.abs(b.y - p.y) <= p.h / 2 + r) {
      b.x = p.x - p.w / 2 - r;
      b.vx = -Math.abs(b.vx);
    }
    // A block is removed when the ball leaves it.
    for (let i = 0; i < this.blocks.length; i++) {
      if (this.blocks[i].overlaps(b)) {
        this.blocks.splice(i, 1);
        b.vx = -b.vx;
        break;
      }
    }
    if (b.x + r >= this.width - 1) {
      this.gameOver();
    } else if (this.blocks.length === 0) {
      this.gameWin();
    }
  }

  protected drawSprites(ctx: CanvasRenderingContext2D): void {
    this.blocks.forEach((k: CYLRefreshGameNode) => {
      ctx.fillStyle = CYLRefreshDrawnColor.alpha(this.colorAccent, k.alpha);
      ctx.fillRect(k.x - k.w / 2, k.y - k.h / 2, k.w, k.h);
    });
    ctx.fillStyle = this.colorAccent;
    const p = this.paddle;
    ctx.fillRect(p.x - p.w / 2, p.y - p.h / 2, p.w, p.h);
    if (!this.ballHidden) {
      const b = this.ball;
      ctx.fillRect(b.x - b.w / 2, b.y - b.h / 2, b.w, b.h);
    }
  }
}

const TANK_ROW_NUM: number = 3;
const TANK_BARREL_RATIO: number = 1 / 3;
const BULLET_NUM_SPACING: number = 200;
const TANK_NUM_SPACING: number = 40;

/** The tank game (iOS BattleCityScene): enemies drive right on 3 rows, the player on the right shoots left. */
export class CYLRefreshGameBattleCityScene extends CYLRefreshGamePlayingScene {
  /** The enemies' and bullets' speeds, in vp/s (SpriteKit's impulses). */
  static tankSpeed: number = 120;
  static bulletSpeed: number = 260;
  /** The row of a new enemy (arc4random() % TANK_ROW_NUM); tests replace it. */
  static randomRow: () => number = () => Math.floor(Math.random() * TANK_ROW_NUM);
  player: CYLRefreshGameNode = new CYLRefreshGameNode(0, 0, 0, 0);
  enemies: CYLRefreshGameNode[] = [];
  bullets: CYLRefreshGameNode[] = [];
  isGameRunning: boolean = false;
  private lastEnemy: CYLRefreshGameNode | null = null;
  private lastBullet: CYLRefreshGameNode | null = null;

  private get sizeTank(): number {
    return this.height / TANK_ROW_NUM;
  }

  reset(): void {
    super.reset();
    const t = this.sizeTank;
    this.isGameRunning = false;
    this.lastEnemy = null;
    this.lastBullet = null;
    this.enemies = [];
    this.bullets = [];
    this.player = new CYLRefreshGameNode(this.width - t / 2, t / 2, t, t);
  }

  start(): void {
    super.start();
    this.isGameRunning = true;
  }

  gameOver(): void {
    super.gameOver();
    this.isGameRunning = false;
  }

  moveHandle(percent: number): void {
    const t = this.sizeTank;
    const p = Math.min(1, Math.max(0, percent));
    this.player.y = (this.height - t) * p + t / 2;
  }

  update(dt: number): void {
    if (!this.isGameRunning) {
      return;
    }
    const t = this.sizeTank;
    const barrel = t * TANK_BARREL_RATIO;
    const enemy = this.lastEnemy;
    if (enemy === null || enemy.x > TANK_NUM_SPACING + t) {
      const e = new CYLRefreshGameNode(t / 2 + 5, t * (0.5 + CYLRefreshGameBattleCityScene.randomRow()), t, t);
      e.vx = CYLRefreshGameBattleCityScene.tankSpeed;
      this.enemies.push(e);
      this.lastEnemy = e;
    }
    const bullet = this.lastBullet;
    if (bullet === null || bullet.x < this.width - t - barrel - BULLET_NUM_SPACING) {
      const b = new CYLRefreshGameNode(this.player.x - t - barrel / 3, this.player.y, barrel, barrel);
      b.vx = -CYLRefreshGameBattleCityScene.bulletSpeed;
      this.bullets.push(b);
      this.lastBullet = b;
    }
    this.enemies.forEach((e: CYLRefreshGameNode) => {
      e.x += e.vx * dt;
    });
    this.bullets.forEach((b: CYLRefreshGameNode) => {
      b.x += b.vx * dt;
    });
    // Contacts: bullet x tank removes both; tank x player is game over; the world's edges remove a node.
    const keptBullets: CYLRefreshGameNode[] = [];
    this.bullets.forEach((b: CYLRefreshGameNode) => {
      const hit = this.enemies.findIndex((e: CYLRefreshGameNode) => e.overlaps(b));
      if (hit >= 0) {
        if (this.enemies[hit] === this.lastEnemy) {
          this.lastEnemy = null;
        }
        this.enemies.splice(hit, 1);
        if (b === this.lastBullet) {
          this.lastBullet = null;
        }
      } else if (b.x - b.w / 2 <= 0) {
        if (b === this.lastBullet) {
          this.lastBullet = null;
        }
      } else {
        keptBullets.push(b);
      }
    });
    this.bullets = keptBullets;
    const playerBox = new CYLRefreshGameNode(this.player.x - barrel / 2, this.player.y, t + barrel, t);
    if (this.enemies.some((e: CYLRefreshGameNode) => e.overlaps(playerBox) && Math.abs(e.y - this.player.y) < t)) {
      this.gameOver();
      return;
    }
    this.enemies = this.enemies.filter((e: CYLRefreshGameNode) => {
      if (e.x + e.w / 2 >= this.width) {
        if (e === this.lastEnemy) {
          this.lastEnemy = null;
        }
        return false;
      }
      return true;
    });
  }

  protected drawSprites(ctx: CanvasRenderingContext2D): void {
    const t = this.sizeTank;
    const half = t / 2;
    const barrel = t * TANK_BARREL_RATIO;
    const pad = (t - barrel) / 2;
    ctx.fillStyle = this.colorAccent;
    const x = this.player.x;
    const y = this.player.y;
    ctx.beginPath();
    ctx.moveTo(x + half, y - half);
    ctx.lineTo(x + half, y + half);
    ctx.lineTo(x - half, y + half);
    ctx.lineTo(x - half, y + half - pad);
    ctx.lineTo(x - half - barrel, y + half - pad);
    ctx.lineTo(x - half - barrel, y + half - pad - barrel);
    ctx.lineTo(x - half, y + half - pad - barrel);
    ctx.lineTo(x - half, y - half);
    ctx.closePath();
    ctx.fill();
    this.enemies.forEach((e: CYLRefreshGameNode) => {
      ctx.beginPath();
      ctx.moveTo(e.x - half, e.y - half);
      ctx.lineTo(e.x - half, e.y + half);
      ctx.lineTo(e.x + half - pad, e.y + half);
      ctx.lineTo(e.x + half - pad, e.y + half - pad);
      ctx.lineTo(e.x + half, e.y + half - pad);
      ctx.lineTo(e.x + half, e.y - half + pad);
      ctx.lineTo(e.x + half - pad, e.y - half + pad);
      ctx.lineTo(e.x + half - pad, e.y - half);
      ctx.closePath();
      ctx.fill();
    });
    this.bullets.forEach((b: CYLRefreshGameNode) => {
      ctx.beginPath();
      ctx.arc(b.x, b.y, barrel / 2, 0, Math.PI * 2);
      ctx.fill();
    });
  }
}

/** The base of the game headers: the game starts while refreshing; drag to play (iOS `CYLRefreshGameHeader`). */
export class CYLRefreshGameHeaderModel extends CYLRefreshDrawnHeaderModel {
  /** The scene shown while pulling (iOS `sceneStart`). */
  sceneStart: CYLRefreshGameStartScene = new CYLRefreshGameStartScene();
  private playing: CYLRefreshGamePlayingScene | null = null;
  private showsPlaying: boolean = false;
  private transitionAt: number = 0;
  private requestFinish: boolean = false;
  private pendingSuccess: boolean = true;

  /** A game header calling `block` when it refreshes. */
  static headerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshGameHeaderModel {
    const header = new CYLRefreshGameHeaderModel();
    header.refreshingBlock = block;
    return header;
  }

  setUpComponent(): void {
    super.setUpComponent();
    this.height = 100;
    this.colorAccent = '#ffffff';
    this.colorPrimary = '#555555';
    this.scrollMode = CYLRefreshScrollMode.Move;
  }

  /** The playing scene, made once by `newPlayingScene` (iOS `scenePlaying`). */
  get scenePlaying(): CYLRefreshGamePlayingScene {
    if (this.playing === null) {
      this.playing = this.newPlayingScene();
    }
    return this.playing as CYLRefreshGamePlayingScene;
  }

  /** The playing scene of the game; the base scene only shows titles (iOS `newPlayingScene`). */
  newPlayingScene(): CYLRefreshGamePlayingScene {
    return new CYLRefreshGamePlayingScene();
  }

  private syncScenes(): void {
    const scene = this.scenePlaying;
    scene.colorAccent = this.cyl_accentColor;
    scene.colorPrimary = this.cyl_primaryColor;
    this.sceneStart.colorAccent = this.cyl_accentColor;
    this.sceneStart.colorPrimary = this.cyl_primaryColor;
    if (scene.width !== this.width || scene.height !== this.expandHeight) {
      scene.width = this.width;
      scene.height = this.expandHeight;
    }
  }

  scrollViewDidScroll(scrollView: CYLRefreshScrollViewModel | null, offset: number, percent: number,
    isDragging: boolean): void {
    super.scrollViewDidScroll(scrollView, offset, percent, isDragging);
    if (this.cyl_isRefreshing() && !isDragging && this.requestFinish) {
      this.requestFinish = false;
      super.finishRefreshWithSuccess(this.pendingSuccess);
    }
  }

  onStatus(oldStatus: CYLRefreshPhase, status: CYLRefreshPhase): void {
    super.onStatus(oldStatus, status);
    if (status === CYLRefreshPhase.Refreshing) {
      this.scrollMode = CYLRefreshScrollMode.Front;
    } else if (status === CYLRefreshPhase.Finishing) {
      this.scrollMode = CYLRefreshScrollMode.Move;
      this.showsPlaying = false;
      this.transitionAt = this.cyl_clock();
    } else if (status === CYLRefreshPhase.Idle) {
      this.showsPlaying = false;
      this.cyl_setNeedsLayout();
    }
  }

  onScrollingWithOffset(offset: number, percent: number, isDragging: boolean): void {
    if (isDragging) {
      this.scenePlaying.moveHandle(Math.min(1, Math.max(percent - 1, 0)));
    }
  }

  finishRefreshWithSuccess(success: boolean): void {
    this.scenePlaying.finishWithSuccess(success);
    const sv = this.scrollView;
    if (sv !== null && sv.isDragging) {
      this.pendingSuccess = success;
      this.requestFinish = true;
    } else {
      super.finishRefreshWithSuccess(success);
    }
  }

  onStartAnimationWhenRefreshing(): void {
    this.syncScenes();
    const scene = this.scenePlaying;
    scene.reset();
    scene.start();
    scene.title = 'Refreshing...';
    this.showsPlaying = true;
    this.transitionAt = this.cyl_clock();
  }

  cyl_touch(touch: CYLRefreshDrawnTouch, x: number, y: number): void {
    if (this.showsPlaying && touch !== CYLRefreshDrawnTouch.Up) {
      this.scenePlaying.moveHandle(y / Math.max(1, this.expandHeight));
    }
  }

  cyl_isAnimating(): boolean {
    return this.transitionAt > 0 && this.cyl_clock() - this.transitionAt < DOORS_DURATION;
  }

  drawInContext(ctx: CanvasRenderingContext2D): void {
    this.syncScenes();
    const w = this.width;
    const h = this.expandHeight;
    const scene = this.scenePlaying;
    if (this.showsPlaying) {
      scene.update(this.cyl_frameSeconds);
    }
    const k = this.transitionAt > 0 ? Math.min(1, (this.cyl_now - this.transitionAt) / DOORS_DURATION) : 1;
    const back = (c: CanvasRenderingContext2D): void => {
      if (this.showsPlaying) {
        scene.drawInContext(c);
      } else {
        this.sceneStart.drawInContext(c, w, h);
      }
    };
    const front = (c: CanvasRenderingContext2D): void => {
      if (this.showsPlaying) {
        this.sceneStart.drawInContext(c, w, h);
      } else {
        scene.drawInContext(c);
      }
    };
    back(ctx);
    if (k >= 1) {
      return;
    }
    // SKTransition doors: opening slides the old scene's halves apart, closing slides the new scene's halves in.
    const half = w / 2;
    const shift = this.showsPlaying ? half * k : half * (1 - k);
    for (let side = 0; side < 2; side++) {
      ctx.save();
      ctx.beginPath();
      if (side === 0) {
        ctx.rect(-shift, 0, half, h);
      } else {
        ctx.rect(half + shift, 0, half, h);
      }
      ctx.clip();
      ctx.translate(side === 0 ? -shift : shift, 0);
      front(ctx);
      ctx.restore();
    }
  }
}

/** The brick breaker played while refreshing (iOS `CYLRefreshGameHitBlockHeader`). */
export class CYLRefreshGameHitBlockHeaderModel extends CYLRefreshGameHeaderModel {
  /** A HitBlock header calling `block` when it refreshes. */
  static headerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshGameHitBlockHeaderModel {
    const header = new CYLRefreshGameHitBlockHeaderModel();
    header.refreshingBlock = block;
    return header;
  }

  newPlayingScene(): CYLRefreshGamePlayingScene {
    return new CYLRefreshGameHitBlockScene();
  }
}

/** The tank game played while refreshing (iOS `CYLRefreshGameBattleCityHeader`). */
export class CYLRefreshGameBattleCityHeaderModel extends CYLRefreshGameHeaderModel {
  /** A BattleCity header calling `block` when it refreshes. */
  static headerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshGameBattleCityHeaderModel {
    const header = new CYLRefreshGameBattleCityHeaderModel();
    header.refreshingBlock = block;
    return header;
  }

  newPlayingScene(): CYLRefreshGamePlayingScene {
    return new CYLRefreshGameBattleCityScene();
  }
}
