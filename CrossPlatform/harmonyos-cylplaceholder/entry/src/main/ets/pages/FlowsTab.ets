// CYLFlowListViewController: how a placeholder is attached to a list (insetGrouped, 3 sections). Section 0 lists the
// CYLFlow cases, section 1 the network status bar, section 2 the HUD. Row glyphs stand in for the SF Symbols.
import { t } from '../common/L10n';
import { Route, RouteParam, push } from '../common/Routes';
import { InsetTable, LargeTitle, TableRow, TableSection } from '../common/Ui';

/** CYLFlow: identifier, title key, API detail (not translated) and the glyph standing in for the SF Symbol. */
class Flow {
  flow: string;
  key: string;
  detail: string;
  icon: string;

  constructor(flow: string, key: string, detail: string, icon: string) {
    this.flow = flow;
    this.key = key;
    this.detail = detail;
    this.icon = icon;
  }
}

export const FLOWS: Flow[] = [
  new Flow('switchStates', 'CYLScenarioTitleSwitchStates', 'reloadData #3', '⟲'),
  new Flow('keepTableHeader', 'CYLScenarioTitleKeepTableHeader', 'frameForPlaceHolderViewInTableView: #17', '▤'),
  new Flow('keepSectionHeaders', 'CYLScenarioTitleKeepSectionHeaders', 'rectForHeaderInSection: #16', '☰'),
  new Flow('refreshControls', 'CYLScenarioTitleRefreshControls', 'cyl_header + cyl_footer #8', '⇩'),
  new Flow('scrollable', 'CYLScenarioTitleScrollable', 'enableScrollWhenPlaceHolderViewShowing', '↕'),
  new Flow('collection', 'CYLScenarioTitleCollection', 'cyl_placeholderViewBlock: #11', '⊞'),
];

function buildSections(): TableSection[] {
  return [
    new TableSection('', FLOWS.map((f: Flow) => new TableRow(f.flow, t(f.key), f.detail, f.icon))),
    new TableSection(t('CYLScenarioSectionStatusBar'), [new TableRow('statusBarFlow', t('CYLScenarioTitleStatusBar'),
      'CYLPlaceholderStatusView · statusView', '❗')]),
    new TableSection(t('CYLScenarioSectionHUD'), [new TableRow('hudFlow', t('CYLScenarioTitleHUD'),
      'CYLPlaceholderHUD · .hud', '⌛')]),
  ];
}

@Component
export struct FlowsTab {
  @State sections: TableSection[] = buildSections();

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
    InsetTable({
      sections: this.sections,
      header: () => {
        this.header()
      },
      onRow: (section: number, row: number) => this.onRow(section, row)
    })
  }
}
