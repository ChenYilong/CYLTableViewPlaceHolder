// The pages pushed on the shell's NavPathStack (the iOS example's pushViewController / present), by name. The
// shell (pages/Index.ets) maps each name to its page in its navDestination builder.
export class Route {
  static readonly Publish: string = 'Publish';
  static readonly ScenarioDetail: string = 'ScenarioDetail';
  static readonly Support: string = 'Support';
  static readonly Configuration: string = 'Configuration';
  static readonly TextFile: string = 'TextFile';
  static readonly AnimationDetail: string = 'AnimationDetail';
  static readonly FlowDetail: string = 'FlowDetail';
  static readonly CollectionFlow: string = 'CollectionFlow';
  static readonly StatusBar: string = 'StatusBar';
  static readonly HUD: string = 'HUD';
  static readonly HUDLifecycle: string = 'HUDLifecycle';
  static readonly RefreshIcons: string = 'RefreshIcons';
  static readonly RefreshIconDemo: string = 'RefreshIconDemo';
  static readonly RefreshTable: string = 'RefreshTable';
  static readonly RefreshTest: string = 'RefreshTest';
  static readonly RefreshCollection: string = 'RefreshCollection';
  static readonly RefreshWeb: string = 'RefreshWeb';
  static readonly RefreshI18n: string = 'RefreshI18n';
  static readonly RefreshSmart: string = 'RefreshSmart';
  static readonly RefreshEasy: string = 'RefreshEasy';
}

/** The parameter of every route: a value (scenario, file, flow, icon id...), an index pair and a title. */
export class RouteParam {
  value: string = '';
  section: number = 0;
  row: number = 0;
  title: string = '';

  static of(value: string, title: string = ''): RouteParam {
    const p = new RouteParam();
    p.value = value;
    p.title = title;
    return p;
  }

  static at(section: number, row: number): RouteParam {
    const p = new RouteParam();
    p.section = section;
    p.row = row;
    return p;
  }
}

/** The AppStorage key of the shell's NavPathStack (pages read it with @StorageLink / AppStorage.get). */
export const PATH_STACK_KEY: string = 'CYLScenarioPathStack';

/** The shell's navigation stack. */
export function pathStack(): NavPathStack {
  let stack = AppStorage.get<NavPathStack>(PATH_STACK_KEY);
  if (stack === undefined) {
    stack = new NavPathStack();
    AppStorage.setOrCreate<NavPathStack>(PATH_STACK_KEY, stack);
  }
  return stack;
}

/** Pushes a page (pushViewController). */
export function push(name: string, param: RouteParam = new RouteParam()): void {
  pathStack().pushPathByName(name, param, true);
}

/** Pops the top page (popViewController / dismiss). */
export function pop(): void {
  pathStack().pop(true);
}
