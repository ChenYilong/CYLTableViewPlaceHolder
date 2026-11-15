// CYLRefreshIconListViewController: every refresh icon of the bundle by engine, then other ways to set an icon.
import { t } from '../common/L10n';
import { Route, RouteParam, push } from '../common/Routes';
import { InsetTable, TableRow, TableSection, UiColor } from '../common/Ui';
import { REFRESH_ICON_SECTIONS, RefreshIconRow, RefreshIconSection } from '../feed/RefreshSetups';

function rowTitle(r: RefreshIconRow): string {
  return r.titleKey ? t(r.title) : r.title;
}

@Component
export struct RefreshIconsPage {
  param: RouteParam = new RouteParam();
  @State sections: TableSection[] = REFRESH_ICON_SECTIONS.map((s: RefreshIconSection) =>
  new TableSection(s.titleKey ? t(s.title) : s.title,
    s.rows.map((r: RefreshIconRow) => new TableRow(r.id, rowTitle(r), r.subtitle))));

  build() {
    NavDestination() {
      InsetTable({
        sections: this.sections,
        onRow: (section: number, row: number) => {
          const r = REFRESH_ICON_SECTIONS[section].rows[row];
          push(Route.RefreshIconDemo, RouteParam.of(r.id, rowTitle(r)));
        }
      })
    }
    .title(t('CYLScenarioRefreshIcons'))
    .backgroundColor(UiColor.groupedBackground)
  }
}
