// CYLFlowListViewController: how a placeholder is attached to a list (insetGrouped, 3 sections). Section 0 lists the
// CYLFlow cases, section 1 the network status bar, section 2 the HUD. Row glyphs stand in for the SF Symbols.
//
// The sectioned list is CollectionViewClassifyMenu's tag list (docs/instructions/examples.md, "Sectioned lists in demos
// use the tag list"), not a table: one section per group with its header, each row a tag with the main title and the
// icon only, More / Less where a section has more rows than it shows, a tap = the row's tap (nothing stays selected),
// and a long press shows the row's detail line in a small callout with an arrow (the tag list's long-press action API).
// A title wraps onto up to TITLE_LINES lines.
import {
  CYLIndexPath, CYLMenuDataSource, CYLMenuDelegate, CYLMenuFoldControl, CYLMenuFoldControlContent,
  CYLMenuFoldControlPosition, CYLMenuSelectionMode, CYLMenuStyle, CYLTagLongPressActions, CYLTagListState,
  CYLTagListView, CYLTagTap, CYLTagTitleMaxLines
} from '@cyl/classifymenu';
import { t } from '../common/L10n';
import { Route, RouteParam, push } from '../common/Routes';
import { LargeTitle, TableRow, TableSection, UiColor } from '../common/Ui';

/** CYLFlow: identifier, title key, API detail (not translated) and the system symbol standing in for the SF Symbol. */
class Flow {
  flow: string;
  key: string;
  detail: string;
  icon: Resource;

  constructor(flow: string, key: string, detail: string, icon: Resource) {
    this.flow = flow;
    this.key = key;
    this.detail = detail;
    this.icon = icon;
  }
}

export const FLOWS: Flow[] = [
  new Flow('switchStates', 'CYLScenarioTitleSwitchStates', 'reloadData #3', $r('sys.symbol.arrow_counterclockwise')),
  new Flow('keepTableHeader', 'CYLScenarioTitleKeepTableHeader', 'frameForPlaceHolderViewInTableView: #17',
    $r('sys.symbol.list_bullet')),
  new Flow('keepSectionHeaders', 'CYLScenarioTitleKeepSectionHeaders', 'rectForHeaderInSection: #16',
    $r('sys.symbol.line_3_horizontal')),
  new Flow('refreshControls', 'CYLScenarioTitleRefreshControls', 'cyl_header + cyl_footer #8',
    $r('sys.symbol.arrow_down')),
  new Flow('scrollable', 'CYLScenarioTitleScrollable', 'enableScrollWhenPlaceHolderViewShowing',
    $r('sys.symbol.arrow_up')),
  new Flow('collection', 'CYLScenarioTitleCollection', 'cyl_placeholderViewBlock: #11', $r('sys.symbol.square_grid_2x2')),
];

/** The most lines a title takes in this example (the tag list leaves the number to the app). */
const TITLE_LINES: number = 3;
/** The rows a section shows before More. */
const VISIBLE_ROWS: number = 2;

/** A row of a section: its title, the detail line shown on a long press and the icon. */
class FlowRow {
  row: TableRow;
  icon: Resource;

  constructor(row: TableRow, icon: Resource) {
    this.row = row;
    this.icon = icon;
  }
}

class FlowSection {
  section: TableSection;
  rows: FlowRow[];

  constructor(section: TableSection, rows: FlowRow[]) {
    this.section = section;
    this.rows = rows;
  }
}

function buildSections(): FlowSection[] {
  const flows: FlowRow[] = FLOWS.map((f: Flow): FlowRow => new FlowRow(new TableRow(f.flow, t(f.key), f.detail), f.icon));
  const status: FlowRow = new FlowRow(new TableRow('statusBarFlow', t('CYLScenarioTitleStatusBar'),
    'CYLPlaceholderStatusView · statusView'), $r('sys.symbol.exclamationmark_circle'));
  const hud: FlowRow = new FlowRow(new TableRow('hudFlow', t('CYLScenarioTitleHUD'), 'CYLPlaceholderHUD · .hud'),
    $r('sys.symbol.hourglass'));
  return [
    new FlowSection(new TableSection(t('CYLScenarioSectionFlows'), []), flows),
    new FlowSection(new TableSection(t('CYLScenarioSectionStatusBar'), []), [status]),
    new FlowSection(new TableSection(t('CYLScenarioSectionHUD'), []), [hud]),
  ];
}

/** The tag list's data: the sections above; the subtitle of a tag is the row's detail line. */
class FlowDataSource implements CYLMenuDataSource {
  private sections: FlowSection[];

  constructor(sections: FlowSection[]) {
    this.sections = sections;
  }

  numberOfSectionsInMenu(): number {
    return this.sections.length;
  }

  menuNumberOfItemsInSection(section: number): number {
    return this.sections[section].rows.length;
  }

  menuTitleForSection(section: number): string {
    return this.sections[section].section.title;
  }

  menuTitleForItem(indexPath: CYLIndexPath): string {
    return this.sections[indexPath.section].rows[indexPath.item].row.title;
  }

  menuSubtitleForItem = (indexPath: CYLIndexPath): string | undefined =>
  this.sections[indexPath.section].rows[indexPath.item].row.subtitle;

  menuImageForItem = (indexPath: CYLIndexPath): Resource => this.sections[indexPath.section].rows[indexPath.item].icon;
}

function buildTagList(sections: FlowSection[]): CYLTagListState {
  const list = new CYLTagListState();
  list.menuDataSource = new FlowDataSource(sections);
  list.selectionMode = CYLMenuSelectionMode.none;
  list.isScrollEnabled = false;
  list.defaultVisibleRows = VISIBLE_ROWS;
  list.foldControl = new CYLMenuFoldControl(CYLMenuFoldControlPosition.headerTrailing, CYLMenuFoldControlContent.iconAndTitle);
  const style = new CYLMenuStyle();
  // numberOfItemsPerRow stays 0: a tag is as wide as its content and a row holds as many tags as fit.
  style.titleMaxLines = TITLE_LINES;
  list.style = style;
  list.longPressAction = CYLTagLongPressActions.callout;
  // A data source set from code is read by reloadMenuData() (a configuration does this itself).
  list.reloadMenuData();
  return list;
}

@Component
export struct FlowsTab {
  @State sections: FlowSection[] = buildSections();
  @State listHeight: number = 0;
  private tagList: CYLTagListState = buildTagList(this.sections);

  aboutToAppear(): void {
    this.tagList.menuDelegate = {
      menuDidChangeContentHeight: (menu: Object, height: number) => {
        this.listHeight = height;
      }
    } as CYLMenuDelegate;
  }

  private onRow(section: number, row: number): void {
    if (section === 1) {
      push(Route.StatusBar);
    } else if (section === 2) {
      push(Route.HUD);
    } else if (FLOWS[row].flow === 'collection') {
      push(Route.CollectionFlow, RouteParam.of('collection'));
    } else {
      push(Route.FlowDetail, RouteParam.of(FLOWS[row].flow));
    }
  }

  @Builder
  header() {
    Column() {
      Row().height(40)
      LargeTitle(t('CYLScenarioSectionFlows'))
    }
  }

  build() {
    Scroll() {
      Column() {
        this.header()
        CYLTagListView({
          tagList: this.tagList,
          onTagTap: (tap: CYLTagTap) => this.onRow(tap.section, tap.item)
        })
          .width('100%')
          .height(this.listHeight)
          .id('flowsTagList')
      }
      .width('100%')
    }
    .align(Alignment.Top)
    .backgroundColor(UiColor.background)
    .width('100%')
    .height('100%')
  }
}
