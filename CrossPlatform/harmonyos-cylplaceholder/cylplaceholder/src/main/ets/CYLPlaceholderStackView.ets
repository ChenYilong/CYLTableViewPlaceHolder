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
import { CYLPlaceholderConfiguration, CYLPlaceholderConfigurationErrorHandler } from './CYLPlaceholderConfiguration';

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
  /** The component id of the view (a configuration's "accessibilityIdentifier"); "" for none. */
  accessibilityIdentifier: string = '';
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

  /**
   * A placeholder from a configuration dictionary (`-initWithConfiguration:actions:error:`): "scenario" (a name),
   * "components" (component dictionaries, replacing the scenario's), "overrides" (dictionaries with an "index" and
   * component fields), "backgroundAction" (an action name, or "" for none) and "accessibilityIdentifier". null, with
   * the reason passed to onError, when a value is invalid.
   */
  static initWithConfiguration(configuration: Record<string, Object> | null,
    actions: Map<CYLPlaceholderAction, CYLPlaceholderActionHandler> | null = null,
    onError: CYLPlaceholderConfigurationErrorHandler | null = null): CYLPlaceholderStackViewModel | null {
    if (configuration === null || !CYLPlaceholderConfiguration.isDictionary(configuration)) {
      return CYLPlaceholderConfiguration.fail(onError, 'The configuration must be a dictionary.');
    }
    let scenario: CYLPlaceholderScenario | null = null;
    const scenarioValue: Object | undefined = configuration['scenario'];
    if (scenarioValue !== undefined) {
      scenario = CYLPlaceholderScenarioCatalog.scenarioNamed(typeof scenarioValue === 'string' ?
        scenarioValue as string : null);
      if (scenario === null) {
        return CYLPlaceholderConfiguration.fail(onError, 'Unknown scenario ' + String(scenarioValue) + '.');
      }
    }
    let components: CYLPlaceholderComponent[] = [];
    const list: Object | undefined = configuration['components'];
    if (list !== undefined && list !== null) {
      if (!Array.isArray(list) || (list as Object[]).length === 0) {
        return CYLPlaceholderConfiguration.fail(onError, '"components" must be a non-empty array.');
      }
      const entries = list as Object[];
      for (let i = 0; i < entries.length; i++) {
        if (!CYLPlaceholderConfiguration.isDictionary(entries[i])) {
          return CYLPlaceholderConfiguration.fail(onError, 'A component must be a dictionary.');
        }
        const c = CYLPlaceholderComponent.componentWithDictionary(entries[i] as Record<string, Object>, onError);
        if (c === null) {
          return null;
        }
        components.push(c);
      }
    } else if (scenario !== null) {
      components = CYLPlaceholderScenarioCatalog.componentsForScenario(scenario);
    } else {
      return CYLPlaceholderConfiguration.fail(onError, 'The configuration needs a "scenario" or "components".');
    }
    const overrides: Object | undefined = configuration['overrides'];
    if (overrides !== undefined && overrides !== null) {
      if (!Array.isArray(overrides)) {
        return CYLPlaceholderConfiguration.fail(onError, '"overrides" must be an array.');
      }
      const items = overrides as Object[];
      for (let i = 0; i < items.length; i++) {
        const fields = CYLPlaceholderConfiguration.isDictionary(items[i]) ? items[i] as Record<string, Object> : null;
        const indexValue: Object | undefined = fields !== null ? fields['index'] : undefined;
        const index = typeof indexValue === 'number' ? Math.floor(indexValue as number) : -1;
        if (fields === null || index < 0 || index >= components.length) {
          return CYLPlaceholderConfiguration.fail(onError, 'Each override needs the "index" of an existing component.');
        }
        const rest: Record<string, Object> = {};
        Object.keys(fields).forEach((k: string) => {
          if (k !== 'index') {
            rest[k] = fields[k];
          }
        });
        if (!CYLPlaceholderConfiguration.applyComponentFields(components[index], rest, onError)) {
          return null;
        }
      }
    }
    const background: Object | undefined = configuration['backgroundAction'];
    if (background !== undefined && background !== null && typeof background !== 'string') {
      return CYLPlaceholderConfiguration.fail(onError, '"backgroundAction" must be an action name.');
    }
    const m = CYLPlaceholderStackViewModel.initWithComponents(components, actions);
    m.scenario = scenario;
    m.backgroundAction = scenario !== null ? CYLPlaceholderScenarioCatalog.backgroundActionForScenario(scenario) : null;
    if (typeof background === 'string') {
      const name = background as string;
      m.backgroundAction = name.length === 0 ? null : CYLPlaceholderScenarioCatalog.actionNamed(name);
    }
    const identifier: Object | undefined = configuration['accessibilityIdentifier'];
    if (typeof identifier === 'string') {
      m.accessibilityIdentifier = identifier as string;
    }
    return m;
  }

  /**
   * The configuration in a local ".json" or ".plist" file, a sandbox path or "file://" URI
   * (`-initWithContentsOfURL:actions:error:`).
   */
  static initWithContentsOfURL(path: string,
    actions: Map<CYLPlaceholderAction, CYLPlaceholderActionHandler> | null = null,
    onError: CYLPlaceholderConfigurationErrorHandler | null = null): CYLPlaceholderStackViewModel | null {
    const configuration = CYLPlaceholderConfiguration.readFile(path, onError);
    return configuration === null ? null :
      CYLPlaceholderStackViewModel.initWithConfiguration(configuration, actions, onError);
  }

  /** Appends a component under the last one and returns its view. */
  appendComponent(component: CYLPlaceholderComponent): CYLPlaceholderViewModel | null {
    if (component.imageBundle !== null && typeof component.image === 'string' &&
      component.imageBundle.imageNamed(component.image as string) === null) {
      // iOS: the image is not in the selected bundle, so the component is not added.
      console.warn('CYLTableViewPlaceHolder: component not added: image "' + (component.image as string) +
        '" was not found in the selected bundle.');
      return null;
    }
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
    .id(this.model.accessibilityIdentifier)
    .onClick(() => {
      const action = this.model.backgroundAction;
      if (this.model.interactive && action !== null) {
        this.model.performAction(action);
      }
    })
  }
}
