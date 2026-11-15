// The HarmonyOS counterpart of iOS CYLPlaceholderStackView: components stacked vertically and centered, the first
// (the reserved icon and title) first, with handlers for their actions. The state lives in the @Observed
// CYLPlaceholderStackViewModel (the iOS initializers and methods); the @Component CYLPlaceholderStackView draws it:
//
//   @State placeholder: CYLPlaceholderStackViewModel = CYLPlaceholderStackViewModel.initWithScenario(
//     CYLPlaceholderScenario.RetryButton, new Map([[CYLPlaceholderActions.Retry, (p, a) => this.reload()]]));
//   ...
//   CYLPlaceholderStackView({ model: this.placeholder })
import { CYLPlaceholderView, CYLPlaceholderViewModel } from './CYLPlaceholderView';
import {
  CYLPlaceholderAction,
  CYLPlaceholderComponent,
  CYLPlaceholderScenario,
  CYLPlaceholderScenarioCatalog
} from './CYLPlaceholderScenario';
import { CYLPlaceholderLocalizedTextForMessage, CYLPlaceholderMessage } from './CYLPlaceholderViewTypes';

/** Runs when a component's action is performed (iOS `CYLPlaceholderActionHandler`). */
export type CYLPlaceholderActionHandler = (placeholder: CYLPlaceholderStackViewModel, action: CYLPlaceholderAction) =>
void;

/** One row of the stack: its view, the action of a tap on it and the space above it. */
@Observed
export class CYLPlaceholderStackEntry {
  view: CYLPlaceholderViewModel;
  action: CYLPlaceholderAction | null;
  spacingBefore: number;
  readonly key: number;

  constructor(view: CYLPlaceholderViewModel, action: CYLPlaceholderAction | null, spacingBefore: number, key: number) {
    this.view = view;
    this.action = action;
    this.spacingBefore = spacingBefore;
    this.key = key;
  }
}

/** The state of a CYLPlaceholderStackView. */
@Observed
export class CYLPlaceholderStackViewModel {
  /** The rows (iOS `stackView.arrangedSubviews`). */
  entries: CYLPlaceholderStackEntry[] = [];
  /** The scenario the view was made from; null when it was made from components (iOS CYLPlaceholderScenarioCount). */
  scenario: CYLPlaceholderScenario | null = null;
  /** The action of a tap outside a tappable component; null turns that off. Set from the scenario. */
  backgroundAction: CYLPlaceholderAction | null = null;
  /** false ignores every tap. */
  interactive: boolean = true;
  private handlers: Map<CYLPlaceholderAction, CYLPlaceholderActionHandler> = new Map();
  private nextKey: number = 0;

  /** Every component view, the reserved one first. */
  get componentViews(): CYLPlaceholderViewModel[] {
    return this.entries.map((e: CYLPlaceholderStackEntry) => e.view);
  }

  /** The reserved first component: the icon and title. */
  get placeholderView(): CYLPlaceholderViewModel {
    return this.entries[0].view;
  }

  /** The scenario's components, with handlers for its actions; an action without a handler does nothing. */
  static initWithScenario(scenario: CYLPlaceholderScenario,
    actions: Map<CYLPlaceholderAction, CYLPlaceholderActionHandler> | null = null): CYLPlaceholderStackViewModel {
    const m = CYLPlaceholderStackViewModel.initWithComponents(
      CYLPlaceholderScenarioCatalog.componentsForScenario(scenario), actions);
    m.scenario = scenario;
    m.backgroundAction = CYLPlaceholderScenarioCatalog.backgroundActionForScenario(scenario);
    return m;
  }

  /** Custom components; the first is the reserved one (a default icon and title when the array is empty). */
  static initWithComponents(components: CYLPlaceholderComponent[],
    actions: Map<CYLPlaceholderAction, CYLPlaceholderActionHandler> | null = null): CYLPlaceholderStackViewModel {
    const m = new CYLPlaceholderStackViewModel();
    if (actions !== null) {
      actions.forEach((handler: CYLPlaceholderActionHandler, action: CYLPlaceholderAction) => {
        m.handlers.set(action, handler);
      });
    }
    const list = components.length > 0 ? components : [CYLPlaceholderComponent.iconComponent('empty',
      CYLPlaceholderLocalizedTextForMessage(CYLPlaceholderMessage.Empty), 160, false)];
    list.forEach((c: CYLPlaceholderComponent, index: number) => {
      const view = m.appendComponent(c);
      if (index === 0 && view !== null) {
        m.entries[0].spacingBefore = 0;
      }
    });
    return m;
  }

  /** Appends a component under the last one and returns its view. */
  appendComponent(component: CYLPlaceholderComponent): CYLPlaceholderViewModel | null {
    const view = CYLPlaceholderViewModel.initWithComponent(component);
    this.appendComponentView(view, component.interactionEnabled ? component.action : null, component.spacingBefore);
    if (component.action !== null && !component.interactionEnabled) {
      // A disabled button still shows as a button; it just does nothing.
      view.tapInteractionEnabled = false;
    }
    return view;
  }

  /** Appends a view the app made itself; a tap on it performs action when that is not null. */
  appendComponentView(view: CYLPlaceholderViewModel, action: CYLPlaceholderAction | null, spacingBefore: number): void {
    if (action !== null) {
      view.tapHandler = (v: CYLPlaceholderViewModel) => {
        if (this.interactive) {
          this.performAction(action);
        }
      };
    }
    this.entries = this.entries.concat([new CYLPlaceholderStackEntry(view, action, spacingBefore, this.nextKey++)]);
  }

  /** Sets or, with null, removes the handler of an action. */
  setHandler(handler: CYLPlaceholderActionHandler | null, action: CYLPlaceholderAction): void {
    if (handler === null) {
      this.handlers.delete(action);
    } else {
      this.handlers.set(action, handler);
    }
  }

  /** The first component whose tap performs action, or null. */
  componentViewForAction(action: CYLPlaceholderAction): CYLPlaceholderViewModel | null {
    for (let i = 0; i < this.entries.length; i++) {
      if (this.entries[i].action === action) {
        return this.entries[i].view;
      }
    }
    return null;
  }

  /** Runs the handler of action; false when it has none. */
  performAction(action: CYLPlaceholderAction): boolean {
    const handler = this.handlers.get(action);
    if (handler === undefined) {
      return false;
    }
    handler(this, action);
    return true;
  }
}

/** One row, observing its entry so the view model's changes re-render it. */
@Component
struct CYLPlaceholderStackRow {
  @ObjectLink entry: CYLPlaceholderStackEntry;

  build() {
    Column() {
      CYLPlaceholderView({ model: this.entry.view })
    }
    .margin({ top: this.entry.spacingBefore })
  }
}

/** Draws a CYLPlaceholderStackViewModel (iOS `CYLPlaceholderStackView`): centered, filling its parent. */
@Component
export struct CYLPlaceholderStackView {
  @ObjectLink model: CYLPlaceholderStackViewModel;

  build() {
    Column() {
      Column() {
        ForEach(this.model.entries, (entry: CYLPlaceholderStackEntry) => {
          CYLPlaceholderStackRow({ entry: entry })
        }, (entry: CYLPlaceholderStackEntry) => entry.key.toString())
      }
      .alignItems(HorizontalAlign.Center)
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      const action = this.model.backgroundAction;
      if (this.model.interactive && action !== null) {
        this.model.performAction(action);
      }
    })
  }
}
