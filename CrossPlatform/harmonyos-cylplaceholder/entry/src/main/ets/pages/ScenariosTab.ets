// CYLScenarioListViewController: every scenario of CYLPlaceholderScenarioCatalog (README screenshots, missing
// permissions, business cases), then the configuration files, in an insetGrouped table. The right bar button is the
// 🌐 language menu (CYLScenarioLanguage): 7 languages + "Follow system"; choosing one rebuilds the interface.
// The SF Symbols of the rows are replaced by the mini program's glyphs.
import {
  CYLPlaceholderAction,
  CYLPlaceholderActions,
  CYLPlaceholderComponent,
  CYLPlaceholderPermission,
  CYLPlaceholderScenario,
  CYLPlaceholderScenarioCatalog,
  CYLPlaceholderScenarioCategory
} from 'cylplaceholder';
import { LANGUAGES, ExampleLanguage, chosenLanguage, effectiveLanguage, setLanguage, t } from '../common/L10n';
import { Route, RouteParam, push } from '../common/Routes';
import { InsetTable, LargeTitle, TableRow, TableSection, UiColor } from '../common/Ui';
import { CONFIGURATION_FILES } from './ConfigurationPage';

// Stand-ins for the iOS SF Symbols of the row icons (text glyphs keep the teal tint, emoji where none fits).
const SYMBOLS: Record<string, string> = {
  'location.slash': '📍',
  'camera': '📷',
  'photo.on.rectangle': '🖼',
  'mic.slash': '🎙',
  'person.2': '👥',
  'calendar': '📅',
  'antenna.radiowaves.left.and.right': '📡',
  'bell.slash': '🔕',
  'lock.shield': '🔒',
  'headphones': '🎧',
  'gearshape': '⚙',
  'cart': '🛒',
  'checkmark.circle': '✓',
  'arrow.clockwise': '↻',
  'rectangle.dashed': '⬚',
  'doc.text': '📄',
};

function permissionSymbol(permission: CYLPlaceholderPermission): string {
  switch (permission) {
    case CYLPlaceholderPermission.Location:
      return 'location.slash';
    case CYLPlaceholderPermission.Camera:
      return 'camera';
    case CYLPlaceholderPermission.PhotoLibrary:
      return 'photo.on.rectangle';
    case CYLPlaceholderPermission.Microphone:
      return 'mic.slash';
    case CYLPlaceholderPermission.Contacts:
      return 'person.2';
    case CYLPlaceholderPermission.Calendar:
      return 'calendar';
    case CYLPlaceholderPermission.Bluetooth:
      return 'antenna.radiowaves.left.and.right';
    case CYLPlaceholderPermission.Notifications:
      return 'bell.slash';
    default:
      return '';
  }
}

/** The permission, else the action a scenario offers, decides its list icon (symbol(for:)). */
function symbolForScenario(scenario: CYLPlaceholderScenario): string {
  const byPermission = permissionSymbol(CYLPlaceholderScenarioCatalog.permissionForScenario(scenario));
  if (byPermission.length > 0) {
    return byPermission;
  }
  if (CYLPlaceholderScenarioCatalog.categoryForScenario(scenario) === CYLPlaceholderScenarioCategory.Permission) {
    return 'lock.shield';
  }
  const actions: CYLPlaceholderAction[] = [];
  CYLPlaceholderScenarioCatalog.componentsForScenario(scenario).forEach((c: CYLPlaceholderComponent) => {
    if (c.action !== null) {
      actions.push(c.action);
    }
  });
  if (actions.includes(CYLPlaceholderActions.ContactSupport)) {
    return 'headphones';
  }
  if (actions.includes(CYLPlaceholderActions.OpenSettings)) {
    return 'gearshape';
  }
  if (actions.includes(CYLPlaceholderActions.GoShopping)) {
    return 'cart';
  }
  if (actions.includes(CYLPlaceholderActions.Done)) {
    return 'checkmark.circle';
  }
  if (actions.includes(CYLPlaceholderActions.Retry) ||
    CYLPlaceholderScenarioCatalog.backgroundActionForScenario(scenario) !== null) {
    return 'arrow.clockwise';
  }
  return 'rectangle.dashed';
}

/** "README #01, #02 · 3 components", or only the component count for a business case. */
function detailForScenario(scenario: CYLPlaceholderScenario): string {
  const components = t('CYLScenarioFormatComponents',
    CYLPlaceholderScenarioCatalog.componentsForScenario(scenario).length);
  const numbers = CYLPlaceholderScenarioCatalog.readmeScreenshotNumbersForScenario(scenario);
  if (numbers.length === 0) {
    return components;
  }
  const list = numbers.map((n: number) => '#' + (n < 10 ? '0' + n : '' + n)).join(', ');
  return t('CYLScenarioFormatReadmeNumbers', list) + ' · ' + components;
}

function scenarioRow(scenario: CYLPlaceholderScenario): TableRow {
  return new TableRow(CYLPlaceholderScenarioCatalog.nameForScenario(scenario),
    CYLPlaceholderScenarioCatalog.localizedNameForScenario(scenario), detailForScenario(scenario),
    SYMBOLS[symbolForScenario(scenario)]);
}

function buildSections(): TableSection[] {
  const all = CYLPlaceholderScenarioCatalog.allScenarios;
  const isPermission = (s: CYLPlaceholderScenario) =>
  CYLPlaceholderScenarioCatalog.categoryForScenario(s) === CYLPlaceholderScenarioCategory.Permission;
  const hasScreenshots = (s: CYLPlaceholderScenario) =>
  CYLPlaceholderScenarioCatalog.readmeScreenshotNumbersForScenario(s).length > 0;
  // File names and initializer names are identifiers and are not translated.
  const files = CONFIGURATION_FILES.map((file: string) => new TableRow(file, file,
    file.endsWith('.plist') ? 'CYLPlaceholderStackView(contentsOf:actions:) · plist' :
      'CYLPlaceholderStackView(contentsOf:) / (configuration:) · JSON', SYMBOLS['doc.text']));
  return [
    new TableSection(t('CYLScenarioSectionReadme'),
      all.filter((s: CYLPlaceholderScenario) => hasScreenshots(s) && !isPermission(s)).map(scenarioRow)),
    new TableSection(t('CYLScenarioSectionPermissions'), all.filter(isPermission).map(scenarioRow)),
    new TableSection(t('CYLScenarioSectionBusiness'),
      all.filter((s: CYLPlaceholderScenario) => !hasScreenshots(s) && !isPermission(s)).map(scenarioRow)),
    new TableSection(t('CYLScenarioSectionConfigurations'), files),
  ];
}

@Component
export struct ScenariosTab {
  @State sections: TableSection[] = buildSections();
  @State menuShown: boolean = false;

  private languageTitle(): string {
    const language = effectiveLanguage();
    let current: ExampleLanguage = LANGUAGES[0];
    LANGUAGES.forEach((l: ExampleLanguage) => {
      if (l.code === language) {
        current = l;
      }
    });
    return '🌐 ' + current.flag + ' ' + current.name;
  }

  private onRow(section: number, row: number): void {
    const key = this.sections[section].rows[row].key;
    if (section === 3) {
      push(Route.Configuration, RouteParam.of(key));
    } else {
      push(Route.ScenarioDetail, RouteParam.of(key));
    }
  }

  /** The pull-down menu titled "Language": one item per language, then "Follow system" (⚙). */
  @Builder
  languageMenu() {
    Menu() {
      MenuItemGroup({ header: t('CYLScenarioLanguage') }) {
        ForEach(LANGUAGES, (l: ExampleLanguage) => {
          MenuItem({ content: l.name })
            .selected(chosenLanguage() === l.code)
            .selectIcon(true)
            .onClick(() => setLanguage(l.code))
        }, (l: ExampleLanguage) => l.code)
        MenuItem({ content: t('CYLScenarioFollowSystem'), labelInfo: '⚙' })
          .selected(chosenLanguage() === '')
          .selectIcon(true)
          .onClick(() => setLanguage(''))
      }
    }
  }

  @Builder
  header() {
    Column() {
      Row() {
        Blank()
        Text(this.languageTitle())
          .fontSize(17)
          .fontColor(UiColor.teal)
          .padding({ left: 8, right: 8, top: 6, bottom: 6 })
          .id('languageButton')
          .bindMenu(this.languageMenu)
      }
      .width('100%')
      .padding({ left: 8, right: 8 })
      LargeTitle(t('CYLScenarioTabScenarios'))
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
