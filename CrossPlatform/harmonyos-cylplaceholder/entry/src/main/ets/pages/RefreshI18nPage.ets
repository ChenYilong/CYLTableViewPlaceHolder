// CYLRefreshI18NExampleViewController: the language of the refresh texts. Two insetGrouped sections of the same 7
// languages (code, and its name in the language in use): "built in" sets CYLRefreshConfig.languageCode and clears the
// custom table; "custom" also sets i18nFilename "CYLRefreshCustom" and i18nBundle to the example's tables (the
// CYLRefreshCustom.strings keys of the example texts, which override only the header texts). An alert confirms. A
// NormalHeader (fading) and an AutoNormalFooter, both ending after 2 s. Leaving gives the app its default texts back.
import {
  CYLRefreshAutoNormalFooterModel,
  CYLRefreshConfig,
  CYLRefreshContainer,
  CYLRefreshFooterView,
  CYLRefreshI18nBundle,
  CYLRefreshNormalHeaderModel,
  CYLRefreshScrollViewModel
} from 'cylplaceholder';
import { ExampleStringTable } from '../common/ExampleStrings';
import { effectiveLanguage, t } from '../common/L10n';
import { RouteParam } from '../common/Routes';
import { SectionHeader, UiColor } from '../common/Ui';

const LANGUAGES: string[] = ['zh-Hans', 'zh-Hant', 'en', 'ru', 'ko', 'uk', 'ja'];
const CUSTOM_TABLE: string = 'CYLRefreshCustom';

/** Locale.current.localizedString(forIdentifier:): each language's name in the language in use. */
const LANGUAGE_NAMES: Record<string, Record<string, string>> = {
  'en': {
    'zh-Hans': 'Chinese, Simplified', 'zh-Hant': 'Chinese, Traditional', 'en': 'English', 'ru': 'Russian',
    'ko': 'Korean', 'uk': 'Ukrainian', 'ja': 'Japanese'
  },
  'zh-Hans': {
    'zh-Hans': '简体中文', 'zh-Hant': '繁体中文', 'en': '英语', 'ru': '俄语', 'ko': '韩语', 'uk': '乌克兰语', 'ja': '日语'
  },
  'zh-Hant': {
    'zh-Hans': '簡體中文', 'zh-Hant': '繁體中文', 'en': '英文', 'ru': '俄文', 'ko': '韓文', 'uk': '烏克蘭文', 'ja': '日文'
  },
  'ja': {
    'zh-Hans': '中国語(簡体字)', 'zh-Hant': '中国語(繁体字)', 'en': '英語', 'ru': 'ロシア語', 'ko': '韓国語',
    'uk': 'ウクライナ語', 'ja': '日本語'
  },
  'ko': {
    'zh-Hans': '중국어(간체)', 'zh-Hant': '중국어(번체)', 'en': '영어', 'ru': '러시아어', 'ko': '한국어',
    'uk': '우크라이나어', 'ja': '일본어'
  },
  'ru': {
    'zh-Hans': 'китайский, упрощенное письмо', 'zh-Hant': 'китайский, традиционное письмо', 'en': 'английский',
    'ru': 'русский', 'ko': 'корейский', 'uk': 'украинский', 'ja': 'японский'
  },
  'uk': {
    'zh-Hans': 'китайська (спрощена)', 'zh-Hant': 'китайська (традиційна)', 'en': 'англійська',
    'ru': 'російська', 'ko': 'корейська', 'uk': 'українська', 'ja': 'японська'
  }
};

/** CYLScenarioExampleBundle(): "language/CYLRefreshCustom" → the CYLRefresh keys of that language's example texts. */
function exampleBundle(): CYLRefreshI18nBundle {
  const bundle: CYLRefreshI18nBundle = new Map<string, Record<string, string>>();
  LANGUAGES.forEach((code: string) => {
    const table = ExampleStringTable(code);
    const own: Record<string, string> = {};
    Object.keys(table).forEach((key: string) => {
      if (key.startsWith('CYLRefresh')) {
        own[key] = table[key];
      }
    });
    bundle.set(code + '/' + CUSTOM_TABLE, own);
  });
  return bundle;
}

@Component
export struct RefreshI18nPage {
  param: RouteParam = new RouteParam();
  private scroller: Scroller = new Scroller();
  private scrollView: CYLRefreshScrollViewModel = new CYLRefreshScrollViewModel();
  private headerTimer: number = -1;
  private footerTimer: number = -1;
  private names: Record<string, string> = LANGUAGE_NAMES['en'];

  aboutToAppear(): void {
    const names = LANGUAGE_NAMES[effectiveLanguage()];
    this.names = names !== undefined ? names : LANGUAGE_NAMES['en'];
    const header = new CYLRefreshNormalHeaderModel();
    header.automaticallyChangeAlpha = true;
    header.refreshingBlock = () => {
      clearTimeout(this.headerTimer);
      this.headerTimer = setTimeout(() => header.endRefreshing(), 2000);
    };
    const footer = new CYLRefreshAutoNormalFooterModel();
    footer.refreshingBlock = () => {
      clearTimeout(this.footerTimer);
      this.footerTimer = setTimeout(() => footer.endRefreshing(), 2000);
    };
    this.scrollView.cyl_header = header;
    this.scrollView.cyl_footer = footer;
    this.scrollView.dataCountProvider = () => LANGUAGES.length * 2;
  }

  aboutToDisappear(): void {
    clearTimeout(this.headerTimer);
    clearTimeout(this.footerTimer);
    // The configuration is shared by the whole app: give the other pages their default texts back.
    const config = CYLRefreshConfig.defaultConfig;
    config.i18nFilename = null;
    config.i18nBundle = null;
    config.languageCode = null;
  }

  private choose(code: string, custom: boolean): void {
    const config = CYLRefreshConfig.defaultConfig;
    if (custom) {
      config.i18nFilename = CUSTOM_TABLE;
      config.i18nBundle = exampleBundle();
    } else {
      config.i18nFilename = null;
      config.i18nBundle = null;
    }
    config.languageCode = code;
    this.getUIContext().showAlertDialog({
      message: t('CYLScenarioMJLanguageChanged', code),
      autoCancel: true,
      alignment: DialogAlignment.Center,
      confirm: { value: t('CYLScenarioMJOK'), action: () => {
      } }
    });
  }

  @Builder
  section(title: string, custom: boolean) {
    Column() {
      SectionHeader(title)
      Column() {
        ForEach(LANGUAGES, (code: string, index: number) => {
          if (index > 0) {
            Divider().strokeWidth(0.5).color(UiColor.separator).margin({ left: 16 })
          }
          Column() {
            Text(code).fontSize(17).fontColor(UiColor.label)
            Text(this.names[code]).fontSize(12).fontColor(UiColor.gray).margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .stateStyles({ pressed: { .backgroundColor(UiColor.pressed) }, normal: { .backgroundColor(UiColor.cell) } })
          .onClick(() => this.choose(code, custom))
        }, (code: string) => (custom ? 'c-' : 'b-') + code)
      }
      .borderRadius(10)
      .clip(true)
      .margin({ left: 16, right: 16 })
    }
  }

  build() {
    NavDestination() {
      CYLRefreshContainer({ scrollView: this.scrollView, scroller: this.scroller }) {
        List({ scroller: this.scroller }) {
          ListItem() {
            this.section(t('CYLScenarioMJI18nBuiltIn'), false)
          }
          ListItem() {
            this.section(t('CYLScenarioMJI18nCustom'), true)
          }
          ListItem() {
            CYLRefreshFooterView({ scrollView: this.scrollView })
          }
        }
        .edgeEffect(EdgeEffect.None)
        .width('100%')
        .height('100%')
      }
    }
    .title(this.param.title)
    .backgroundColor(UiColor.groupedBackground)
  }
}
