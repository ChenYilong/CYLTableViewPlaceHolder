// CYLRefreshTestViewController: a blank page titled "Test view controller" with a "Close" bar button. Every refresh
// list opens it with `showRefreshTest(row)`: odd rows push it, even rows present it (iOS presents it in its own
// navigation controller). HarmonyOS has one NavPathStack, so a presented page is a NavDestination that comes up from
// the bottom (systemTransition SLIDE_BOTTOM) without a back button, as a modal does; "Close" pops it either way.
import { t } from '../common/L10n';
import { Route, RouteParam, pop, push } from '../common/Routes';
import { BarButton, NavTitle } from '../common/Ui';

/** CYLRefreshTestViewController.show(from:row:): pushes on odd rows, presents on even rows. */
export function showRefreshTest(row: number): void {
  push(Route.RefreshTest, RouteParam.of(row % 2 === 1 ? 'push' : 'modal'));
}

@Component
export struct RefreshTestPage {
  param: RouteParam = new RouteParam();

  @Builder
  barItems() {
    Row() {
      BarButton(t('CYLScenarioMJClose'), () => pop())
    }
    .height('100%')
  }

  @Builder
  navTitle() {
    NavTitle(t('CYLScenarioMJTestTitle'))
  }

  build() {
    NavDestination() {
      Column()
        .width('100%')
        .height('100%')
    }
    .title(this.navTitle)
    .menus(this.barItems)
    .backgroundColor(Color.White)
    .hideBackButton(this.param.value === 'modal')
    .systemTransition(this.param.value === 'modal' ? NavigationSystemTransitionType.SLIDE_BOTTOM :
      NavigationSystemTransitionType.DEFAULT)
  }
}
