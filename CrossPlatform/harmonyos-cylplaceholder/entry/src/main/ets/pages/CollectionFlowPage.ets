// CYLCollectionFlowViewController: a grid (104 x 104 items, spacing 8, insets 12) with the NoFavorites placeholder
// (no actions) while it is empty, through the block API (cyl_placeholderViewBlock:, issue #11). "Add" toggles 0 / 18
// items and becomes "Clear".
import {
  CYLPlaceholderCollectionController,
  CYLPlaceholderList,
  CYLPlaceholderListController,
  CYLPlaceholderScenario,
  CYLPlaceholderStackViewModel
} from 'cylplaceholder';
import { t } from '../common/L10n';
import { RouteParam } from '../common/Routes';
import { BarButton } from '../common/Ui';

/** UIColor(hue:saturation:brightness:) as a #rrggbb string. */
function hsb(h: number, s: number, v: number): string {
  const i = Math.floor(h * 6);
  const f = h * 6 - i;
  const p = v * (1 - s);
  const q = v * (1 - f * s);
  const u = v * (1 - (1 - f) * s);
  const table: number[][] = [[v, u, p], [q, v, p], [p, v, u], [p, q, v], [u, p, v], [v, p, q]];
  const rgb = table[i % 6];
  return '#' + rgb.map((c: number) => ('0' + Math.round(c * 255).toString(16)).slice(-2)).join('');
}

@Component
export struct CollectionFlowPage {
  param: RouteParam = new RouteParam();
  @State colors: string[] = [];
  @State collection: CYLPlaceholderCollectionController = new CYLPlaceholderListController(() => this.colors.length);

  aboutToAppear(): void {
    this.collection.cyl_placeholderViewBlock((c: CYLPlaceholderListController) =>
    CYLPlaceholderStackViewModel.initWithScenario(CYLPlaceholderScenario.NoFavorites));
  }

  private toggleItems(): void {
    const count = this.colors.length > 0 ? 0 : 18;
    const colors: string[] = [];
    for (let i = 0; i < count; i++) {
      colors.push(hsb((i % 12) / 12, 0.35, 0.95));
    }
    this.colors = colors;
    this.collection.reloadData();
  }

  @Builder
  barItems() {
    Row() {
      BarButton(t(this.colors.length > 0 ? 'CYLScenarioActionClear' : 'CYLScenarioActionAdd'),
        () => this.toggleItems())
    }
    .height('100%')
  }

  build() {
    NavDestination() {
      CYLPlaceholderList({ controller: this.collection }) {
        Grid() {
          ForEach(this.colors, (color: string, index: number) => {
            GridItem() {
              Column().width(104).height(104).backgroundColor(color)
            }
          }, (color: string, index: number) => index + color)
        }
        .columnsTemplate('repeat(auto-fill, 104)')
        .columnsGap(8)
        .rowsGap(8)
        .padding(12)
        .width('100%')
        .height('100%')
      }
    }
    .title(t('CYLScenarioTitleCollection'))
    .menus(this.barItems)
    .backgroundColor(Color.White)
  }
}
