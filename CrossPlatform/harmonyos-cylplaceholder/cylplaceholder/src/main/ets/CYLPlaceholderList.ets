// The HarmonyOS counterpart of iOS UITableView+CYLPlaceholder, UICollectionView+CYLPlaceholder,
// UITableView+CYLTableViewPlaceHolder (`cyl_reloadData`), CYLTableViewPlaceHolderDelegate and
// UIScrollView (CYLPlaceholderVisibility), with the behavior of android/placeholder's CYLTableViewPlaceHolder.kt.
// ArkUI has no table view object to extend, so a CYLPlaceholderListController stands for the UITableView /
// UICollectionView: it knows the list's item count and the placeholder blocks, and the CYLPlaceholderList component
// shows either the List / Grid the app builds or the placeholder when the list is empty:
//
//   @State list: CYLPlaceholderListController = new CYLPlaceholderListController(() => this.items.length);
//   aboutToAppear() {
//     this.list.cyl_placeholderViewBlock((tableView) => CYLPlaceholderStackViewModel.initWithScenario(
//       CYLPlaceholderScenario.NoContent));
//   }
//   ...
//   CYLPlaceholderList({ controller: this.list }) { List() { ForEach(this.items, ...) } }
//   // after the data changes:
//   this.list.cyl_reloadData();
import { CYLPlaceholderStackView, CYLPlaceholderStackViewModel } from './CYLPlaceholderStackView';
import { CYLPlaceholderView, CYLPlaceholderViewModel } from './CYLPlaceholderView';

/** What a placeholder block returns: a stack (scenario, components) or a single icon-and-title view. */
export type CYLPlaceholderListPlaceholder = CYLPlaceholderStackViewModel | CYLPlaceholderViewModel;

/** Makes the placeholder of an empty list, or null for none (iOS `CYLTablePlaceholderViewBlock`). */
export type CYLTablePlaceholderViewBlock = (tableView: CYLPlaceholderListController) => CYLPlaceholderListPlaceholder |
null;
/** Runs when the list has data again (iOS `CYLTablePlaceholderNormalBlock`). */
export type CYLTablePlaceholderNormalBlock = (tableView: CYLPlaceholderListController) => void;
/** The same as CYLTablePlaceholderViewBlock, for a Grid (iOS `CYLCollectionPlaceholderViewBlock`). */
export type CYLCollectionPlaceholderViewBlock = CYLTablePlaceholderViewBlock;
/** The same as CYLTablePlaceholderNormalBlock, for a Grid (iOS `CYLCollectionPlaceholderNormalBlock`). */
export type CYLCollectionPlaceholderNormalBlock = CYLTablePlaceholderNormalBlock;

/** A frame inside the list's bounds, in vp. */
export class CYLPlaceholderRect {
  x: number = 0;
  y: number = 0;
  width: number = 0;
  height: number = 0;

  constructor(x: number = 0, y: number = 0, width: number = 0, height: number = 0) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
  }
}

/**
 * Gives an empty list its placeholder without a block (iOS `CYLTableViewPlaceHolderDelegate`): set it as the
 * controller's delegate and call cyl_reloadData.
 */
export interface CYLTableViewPlaceHolderDelegate {
  /** The placeholder to show while the list is empty (iOS `-makePlaceHolderView`). */
  makePlaceHolderView: () => CYLPlaceholderListPlaceholder;
  /** Whether the empty list still scrolls, for a pull to refresh (iOS `-enableScrollWhenPlaceHolderViewShowing`). */
  enableScrollWhenPlaceHolderViewShowing?: () => boolean;
  /** The placeholder's frame in the list's bounds, or null for all of them (iOS `-frameForPlaceHolderViewInTableView:`). */
  frameForPlaceHolderViewInTableView?: (tableView: CYLPlaceholderListController) => CYLPlaceholderRect | null;
}

/**
 * Stands for a UITableView / UICollectionView (iOS categories UITableView (CYLPlaceholder), UICollectionView
 * (CYLPlaceholder), UITableView (CYLTableViewPlaceHolder) and UIScrollView (CYLPlaceholderVisibility)).
 */
@Observed
export class CYLPlaceholderListController {
  /** The number of items the list shows (the data source count). */
  itemCount: () => number;
  /** The placeholder shown now, or null (the list shows). */
  placeholder: CYLPlaceholderListPlaceholder | null = null;
  /** The shown placeholder when it is a stack (for drawing). */
  stackPlaceholder: CYLPlaceholderStackViewModel | null = null;
  /** The shown placeholder when it is a single view (for drawing). */
  viewPlaceholder: CYLPlaceholderViewModel | null = null;
  /** Whether the shown placeholder scrolls (enableScrollWhenPlaceHolderViewShowing). */
  placeholderScrollEnabled: boolean = false;
  /** The shown placeholder's frame, or null to fill the list (frameForPlaceHolderViewInTableView). */
  placeholderFrame: CYLPlaceholderRect | null = null;
  /** The placeholder provider of cyl_reloadData when no block is set (iOS: the data source as the delegate). */
  delegate: CYLTableViewPlaceHolderDelegate | null = null;
  /** Bumped every time a placeholder is made, so the component rebuilds it. */
  placeholderGeneration: number = 0;
  private viewBlock: CYLTablePlaceholderViewBlock | null = null;
  private normalBlock: CYLTablePlaceholderNormalBlock | null = null;
  private hiddenValue: boolean = false;

  constructor(itemCount: () => number = () => 0) {
    this.itemCount = itemCount;
  }

  /** The placeholder shown for this list now, or null (iOS `cyl_placeholderView`). */
  get cyl_placeholderView(): CYLPlaceholderListPlaceholder | null {
    return this.placeholder;
  }

  /** Whether the list is empty now. */
  get isEmpty(): boolean {
    return this.itemCount() <= 0;
  }

  /**
   * Shows the placeholder placeholderViewBlock makes whenever the list is empty, from now on; null stops it and
   * restores the list (iOS `-cyl_placeholderViewBlock:`).
   */
  cyl_placeholderViewBlock(placeholderViewBlock: CYLTablePlaceholderViewBlock | null): void {
    this.cyl_placeholderViewBlockBackToNormalBlock(placeholderViewBlock, null);
  }

  /**
   * As cyl_placeholderViewBlock, running backToNormalBlock when the list has data again
   * (iOS `-cyl_placeholderViewBlock:backToNormalBlock:`).
   */
  cyl_placeholderViewBlockBackToNormalBlock(placeholderViewBlock: CYLTablePlaceholderViewBlock | null,
    backToNormalBlock: CYLTablePlaceholderNormalBlock | null): void {
    this.viewBlock = placeholderViewBlock;
    this.normalBlock = backToNormalBlock;
    this.update(false);
  }

  /**
   * Reloads: shows or removes the placeholder for the current item count (iOS `-cyl_reloadData`). A reload while the
   * list stays empty asks for a new placeholder, so a state change (loading, then failed) shows at once.
   */
  cyl_reloadData(): void {
    this.update(true);
  }

  /** Shows or removes the placeholder after a data change, keeping the shown one while the list stays empty (iOS `reloadData`). */
  reloadData(): void {
    this.update(false);
  }

  /** true keeps the placeholder from showing even while the list is empty (iOS `cyl_placeholderHidden`). */
  get cyl_placeholderHidden(): boolean {
    return this.hiddenValue;
  }

  set cyl_placeholderHidden(value: boolean) {
    this.hiddenValue = value;
    this.update(false);
  }

  private update(rebuild: boolean): void {
    const delegate = this.delegate;
    const empty = this.isEmpty;
    if (!empty || this.hiddenValue || (this.viewBlock === null && delegate === null)) {
      if (this.placeholder !== null) {
        this.remove();
        const normal = this.normalBlock;
        if (normal !== null && !empty) {
          normal(this);
        }
      }
      return;
    }
    if (this.placeholder !== null && !rebuild) {
      return;
    }
    const block = this.viewBlock;
    let made: CYLPlaceholderListPlaceholder | null = null;
    if (block !== null) {
      made = block(this);
    } else if (delegate !== null) {
      made = delegate.makePlaceHolderView();
    }
    if (made === null) {
      this.remove();
      return;
    }
    this.placeholderScrollEnabled = block === null && delegate !== null &&
      delegate.enableScrollWhenPlaceHolderViewShowing !== undefined && delegate.enableScrollWhenPlaceHolderViewShowing();
    this.placeholderFrame = block === null && delegate !== null && delegate.frameForPlaceHolderViewInTableView !==
      undefined ? delegate.frameForPlaceHolderViewInTableView(this) : null;
    this.placeholderGeneration++;
    this.stackPlaceholder = made instanceof CYLPlaceholderStackViewModel ? made as CYLPlaceholderStackViewModel : null;
    this.viewPlaceholder = made instanceof CYLPlaceholderViewModel ? made as CYLPlaceholderViewModel : null;
    this.placeholder = made;
  }

  private remove(): void {
    this.placeholder = null;
    this.stackPlaceholder = null;
    this.viewPlaceholder = null;
    this.placeholderFrame = null;
    this.placeholderScrollEnabled = false;
  }
}

/** A UITableView-named alias of the controller (iOS UITableView (CYLPlaceholder)). */
export type CYLPlaceholderTableController = CYLPlaceholderListController;
/** A UICollectionView-named alias of the controller, for a Grid (iOS UICollectionView (CYLPlaceholder)). */
export type CYLPlaceholderCollectionController = CYLPlaceholderListController;

/** Shows a list (the content the app builds) or, while the controller has one, its placeholder. */
@Component
export struct CYLPlaceholderList {
  @ObjectLink controller: CYLPlaceholderListController;
  @BuilderParam content: () => void = emptyContent;

  @Builder
  placeholderContent() {
    if (this.controller.stackPlaceholder !== null) {
      CYLPlaceholderStackView({ model: this.controller.stackPlaceholder })
    } else if (this.controller.viewPlaceholder !== null) {
      CYLPlaceholderView({ model: this.controller.viewPlaceholder })
    }
  }

  @Builder
  framedPlaceholder() {
    if (this.controller.placeholderFrame !== null) {
      Stack() {
        this.placeholderContent()
      }
      .position({ x: this.controller.placeholderFrame.x, y: this.controller.placeholderFrame.y })
      .width(this.controller.placeholderFrame.width)
      .height(this.controller.placeholderFrame.height)
    } else {
      this.placeholderContent()
    }
  }

  build() {
    Stack() {
      if (this.controller.placeholder === null) {
        this.content()
      } else if (this.controller.placeholderScrollEnabled) {
        Scroll() {
          Stack() {
            this.framedPlaceholder()
          }
          .width('100%')
          .constraintSize({ minHeight: '100%' })
        }
        .width('100%')
        .height('100%')
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      } else {
        Stack() {
          this.framedPlaceholder()
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
}

@Builder
function emptyContent() {
}
