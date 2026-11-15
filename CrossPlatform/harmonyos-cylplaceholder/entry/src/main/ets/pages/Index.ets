// The app shell of the iOS example (CYLScenarioAppDelegate + CYLScenarioTabBarController): five tabs (Scenarios,
// Animations, Flows, Feed, Refresh) in a tab bar tinted systemTeal, and the raised teal plus button at index 3
// (84 x 84, image 66, center Y -24) that presents the Publish page. CYLTabBarController has no HarmonyOS port, so the
// bar is an ArkUI Tabs with a custom bar (the SF Symbols are replaced by the mini program's SVG icons).
// Every pushed page lives on one NavPathStack (common/Routes.ets). Choosing a language rebuilds the whole interface
// and goes back to the first tab, as the iOS example's cyl_setRootViewControllerProvider does.
import { CYLPlaceholderHUD } from 'cylplaceholder';
import { EXAMPLE_GENERATION_KEY, applyStoredLanguage, t } from '../common/L10n';
import { Route, RouteParam, pathStack, push } from '../common/Routes';
import { UiColor } from '../common/Ui';
import { ScenariosTab } from './ScenariosTab';
import { AnimationsTab } from './AnimationsTab';
import { FlowsTab } from './FlowsTab';
import { FeedTab } from './FeedTab';
import { RefreshTab } from './RefreshTab';
import { PublishPage } from './PublishPage';
import { ScenarioDetailPage } from './ScenarioDetailPage';
import { SupportPage } from './SupportPage';
import { ConfigurationPage } from './ConfigurationPage';
import { TextFilePage } from './TextFilePage';
import { AnimationDetailPage } from './AnimationDetailPage';
import { FlowDetailPage } from './FlowDetailPage';
import { CollectionFlowPage } from './CollectionFlowPage';
import { StatusBarPage } from './StatusBarPage';
import { HUDPage } from './HUDPage';
import { HUDLifecyclePage } from './HUDLifecyclePage';
import { RefreshIconsPage } from './RefreshIconsPage';
import { RefreshIconDemoPage } from './RefreshIconDemoPage';
import { RefreshDemo } from './RefreshDemo';

/** One tab: identifier, title key and the icons (rawfile/example/tab, from the mini program). */
class Tab {
  identifier: string;
  titleKey: string;
  icon: Resource;
  selectedIcon: Resource;

  constructor(identifier: string, titleKey: string, icon: Resource, selectedIcon: Resource) {
    this.identifier = identifier;
    this.titleKey = titleKey;
    this.icon = icon;
    this.selectedIcon = selectedIcon;
  }
}

const TABS: Tab[] = [
  new Tab('scenarios', 'CYLScenarioTabScenarios', $rawfile('example/tab/stack.svg'),
    $rawfile('example/tab/stack_selected.svg')),
  new Tab('animations', 'CYLScenarioTabAnimations', $rawfile('example/tab/sparkles.svg'),
    $rawfile('example/tab/sparkles_selected.svg')),
  new Tab('flows', 'CYLScenarioSectionFlows', $rawfile('example/tab/branch.svg'),
    $rawfile('example/tab/branch_selected.svg')),
  new Tab('feed', 'CYLScenarioTabFeed', $rawfile('example/tab/bubbles.svg'),
    $rawfile('example/tab/bubbles_selected.svg')),
  new Tab('refresh', 'CYLScenarioTabRefresh', $rawfile('example/tab/refresh.svg'),
    $rawfile('example/tab/refresh_selected.svg')),
];

/** The index of the plus button among the bar's items (indexOfPlusButtonInTabBar). */
const PLUS_INDEX: number = 3;
const BAR_HEIGHT: number = 49;
const PLUS_SIZE: number = 84;
const PLUS_IMAGE_SIZE: number = 66;
const PLUS_CENTER_Y_OFFSET: number = -24;

@Entry
@Component
struct Index {
  @StorageLink(EXAMPLE_GENERATION_KEY) @Watch('onLanguageChanged') generation: number = 0;
  @State selected: number = 0;
  private stack: NavPathStack = pathStack();
  private controller: TabsController = new TabsController();

  aboutToAppear(): void {
    applyStoredLanguage(this.getUIContext().getHostContext()!);
    CYLPlaceholderHUD.sharedHUD.containerView = this.getUIContext();
  }

  /** setLanguage: back to the first tab, every page closed, every text rebuilt. */
  onLanguageChanged(): void {
    this.stack.clear(false);
    this.selected = 0;
  }

  @Builder
  routes(name: string, param: Object) {
    if (name === Route.Publish) {
      PublishPage()
    } else if (name === Route.ScenarioDetail) {
      ScenarioDetailPage({ param: param as RouteParam })
    } else if (name === Route.Support) {
      SupportPage()
    } else if (name === Route.Configuration) {
      ConfigurationPage({ param: param as RouteParam })
    } else if (name === Route.TextFile) {
      TextFilePage({ param: param as RouteParam })
    } else if (name === Route.AnimationDetail) {
      AnimationDetailPage({ param: param as RouteParam })
    } else if (name === Route.FlowDetail) {
      FlowDetailPage({ param: param as RouteParam })
    } else if (name === Route.CollectionFlow) {
      CollectionFlowPage({ param: param as RouteParam })
    } else if (name === Route.StatusBar) {
      StatusBarPage({ param: param as RouteParam })
    } else if (name === Route.HUD) {
      HUDPage({ param: param as RouteParam })
    } else if (name === Route.HUDLifecycle) {
      HUDLifecyclePage({ param: param as RouteParam })
    } else if (name === Route.RefreshIcons) {
      RefreshIconsPage({ param: param as RouteParam })
    } else if (name === Route.RefreshIconDemo) {
      RefreshIconDemoPage({ param: param as RouteParam })
    } else if (name === Route.RefreshDemo) {
      NavDestination() {
        RefreshDemo()
      }
      .title('CYLRefresh')
    }
  }

  @Builder
  tabContent(identifier: string) {
    if (identifier === 'scenarios') {
      ScenariosTab()
    } else if (identifier === 'animations') {
      AnimationsTab()
    } else if (identifier === 'flows') {
      FlowsTab()
    } else if (identifier === 'feed') {
      FeedTab()
    } else {
      RefreshTab()
    }
  }

  @Builder
  barItem(tab: Tab, index: number) {
    Column() {
      Image(index === this.selected ? tab.selectedIcon : tab.icon)
        .width(26)
        .height(26)
        .objectFit(ImageFit.Contain)
      Text(t(tab.titleKey))
        .fontSize(10)
        .fontColor(index === this.selected ? UiColor.teal : UiColor.gray)
        .margin({ top: 2 })
        .maxLines(1)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .accessibilityText(t(tab.titleKey))
    .onClick(() => {
      this.selected = index;
      this.controller.changeIndex(index);
    })
  }

  @Builder
  shell() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        Tabs({ index: this.selected, controller: this.controller }) {
          ForEach(TABS, (tab: Tab) => {
            TabContent() {
              this.tabContent(tab.identifier)
            }
          }, (tab: Tab) => tab.identifier)
        }
        .barHeight(0)
        .scrollable(false)
        .animationDuration(0)
        .layoutWeight(1)
        .onChange((index: number) => {
          this.selected = index;
        })

        // The tab bar: the five items with an empty slot for the plus button at PLUS_INDEX.
        Column() {
          Divider().strokeWidth(0.5).color(UiColor.separator)
          Row() {
            ForEach(TABS, (tab: Tab, index: number) => {
              if (index === PLUS_INDEX) {
                Column().layoutWeight(1).height('100%')
              }
              this.barItem(tab, index)
            }, (tab: Tab) => tab.identifier)
          }
          .height(BAR_HEIGHT)
          .width('100%')
        }
        .backgroundColor('#F9F9F9')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%')

      // The plus button, raised above the bar: its center sits 24 above the bar's center.
      Row() {
        Column().layoutWeight(PLUS_INDEX).hitTestBehavior(HitTestMode.Transparent)
        Column() {
          Column() {
            Image($rawfile('example/tab/plus.svg'))
              .width(PLUS_IMAGE_SIZE)
              .height(PLUS_IMAGE_SIZE)
              .objectFit(ImageFit.Contain)
          }
          .width(PLUS_SIZE)
          .height(PLUS_SIZE)
          .justifyContent(FlexAlign.Center)
          .id('plusButton')
          .accessibilityText(t('CYLScenarioActionPublish'))
          .onClick(() => push(Route.Publish, new RouteParam()))
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .hitTestBehavior(HitTestMode.Transparent)
        Column().layoutWeight(TABS.length - PLUS_INDEX).hitTestBehavior(HitTestMode.Transparent)
      }
      .width('100%')
      .height(PLUS_SIZE)
      .justifyContent(FlexAlign.Center)
      .hitTestBehavior(HitTestMode.Transparent)
      .margin({ bottom: BAR_HEIGHT / 2 - PLUS_CENTER_Y_OFFSET - PLUS_SIZE / 2 })
    }
    .width('100%')
    .height('100%')
  }

  build() {
    Navigation(this.stack) {
      // Keyed by the language generation: a new language builds every tab again.
      ForEach([this.generation], (generation: number) => {
        this.shell()
      }, (generation: number) => 'shell-' + generation)
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .mode(NavigationMode.Stack)
    .navDestination(this.routes)
    .backgroundColor(UiColor.groupedBackground)
  }
}
