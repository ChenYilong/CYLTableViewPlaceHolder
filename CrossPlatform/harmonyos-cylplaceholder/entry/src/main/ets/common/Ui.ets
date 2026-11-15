// Shared looks of the example: the iOS table styles (insetGrouped / plain), bar buttons and texts, as in the mini
// program's app.wxss. Colors are iOS system colors (light values; dark mode via resources would follow the system).

export class UiColor {
  static readonly teal: string = '#30B0C7'; // UIColor.systemTeal
  static readonly gray: string = '#8E8E93';
  static readonly groupedBackground: string = '#F2F2F7';
  static readonly cell: string = '#FFFFFF';
  static readonly pressed: string = '#D1D1D6';
  static readonly separator: string = '#C6C6C8';
  static readonly sectionHeader: string = '#6D6D72';
  static readonly chevron: string = '#C4C4C7';
  static readonly destructive: string = '#FF3B30';
  static readonly label: string = '#000000';
}

/** A row of an insetGrouped / plain table. */
export class TableRow {
  key: string;
  title: string;
  subtitle: string;
  icon: string;
  detail: string;
  chevron: boolean;
  checked: boolean;

  constructor(key: string, title: string, subtitle: string = '', icon: string = '', chevron: boolean = true) {
    this.key = key;
    this.title = title;
    this.subtitle = subtitle;
    this.icon = icon;
    this.detail = '';
    this.chevron = chevron;
    this.checked = false;
  }
}

/** A section of an insetGrouped table. */
export class TableSection {
  title: string;
  rows: TableRow[];
  footer: string;

  constructor(title: string, rows: TableRow[], footer: string = '') {
    this.title = title;
    this.rows = rows;
    this.footer = footer;
  }
}

/** The large title of a tab's root page, with right bar buttons drawn by the caller. */
@Builder
export function LargeTitle(title: string) {
  Text(title)
    .fontSize(34)
    .fontWeight(FontWeight.Bold)
    .fontColor(UiColor.label)
    .width('100%')
    .padding({ left: 16, right: 16, top: 4, bottom: 8 })
}

/** A bar button item (teal text). */
@Builder
export function BarButton(title: string, action: () => void) {
  Text(title)
    .fontSize(17)
    .fontColor(UiColor.teal)
    .padding({ left: 8, right: 8, top: 6, bottom: 6 })
    .stateStyles({ pressed: { .opacity(0.5) }, normal: { .opacity(1) } })
    .onClick(action)
}

/** The gray uppercase header of an insetGrouped section. */
@Builder
export function SectionHeader(title: string) {
  Text(title.toUpperCase())
    .fontSize(13)
    .fontColor(UiColor.sectionHeader)
    .width('100%')
    .padding({ left: 32, right: 32, top: 18, bottom: 6 })
}

/** The gray footer of an insetGrouped section. */
@Builder
export function SectionFooter(title: string) {
  Text(title)
    .fontSize(13)
    .lineHeight(18)
    .fontColor(UiColor.sectionHeader)
    .width('100%')
    .padding({ left: 32, right: 32, top: 6 })
}

/** One cell: optional leading glyph, title, subtitle, trailing detail, check mark or chevron. */
@Builder
export function TableCell(row: TableRow, action: () => void) {
  Row() {
    if (row.icon.length > 0) {
      Text(row.icon)
        .fontSize(18)
        .fontColor(UiColor.teal)
        .width(26)
        .textAlign(TextAlign.Center)
        .margin({ right: 12 })
    }
    Column() {
      Text(row.title).fontSize(17).fontColor(UiColor.label)
      if (row.subtitle.length > 0) {
        Text(row.subtitle).fontSize(12).fontColor(UiColor.gray).margin({ top: 2 })
      }
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
    if (row.detail.length > 0) {
      Text(row.detail).fontSize(17).fontColor(UiColor.gray).margin({ left: 8 })
    }
    if (row.checked) {
      Text('✓').fontSize(17).fontColor(UiColor.teal).margin({ left: 8 })
    }
    if (row.chevron) {
      Text('›').fontSize(20).fontColor(UiColor.chevron).margin({ left: 8 })
    }
  }
  .width('100%')
  .constraintSize({ minHeight: 44 })
  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
  .backgroundColor(UiColor.cell)
  .stateStyles({
    pressed: { .backgroundColor(UiColor.pressed) },
    normal: { .backgroundColor(UiColor.cell) }
  })
  .onClick(action)
}

/** Formats a byte count like ByteCountFormatter (.file style): "981 bytes", "12 KB", "1.2 MB". */
export function formatBytes(bytes: number): string {
  if (bytes === 0) {
    return 'Zero KB';
  }
  if (bytes < 1000) {
    return bytes === 1 ? '1 byte' : bytes + ' bytes';
  }
  if (bytes < 1000 * 1000) {
    return Math.round(bytes / 1000) + ' KB';
  }
  return (bytes / 1000 / 1000).toFixed(1) + ' MB';
}

/** Called with the section and row index of a tapped row. */
export type TableRowAction = (section: number, row: number) => void;

/**
 * An insetGrouped UITableView: sections of rounded cards with gray headers and footers. `header` is drawn above the
 * first section (a tab's large title and bar buttons). Pass a new `sections` array to reload.
 */
@Component
export struct InsetTable {
  @Prop sections: TableSection[] = [];
  @BuilderParam header: () => void = EmptyHeader;
  onRow: TableRowAction = (section: number, row: number) => {
  };

  build() {
    List() {
      ListItem() {
        this.header()
      }
      ForEach(this.sections, (section: TableSection, s: number) => {
        ListItem() {
          Column() {
            if (section.title.length > 0) {
              SectionHeader(section.title)
            }
            Column() {
              ForEach(section.rows, (row: TableRow, r: number) => {
                if (r > 0) {
                  Divider().strokeWidth(0.5).color(UiColor.separator).margin({ left: row.icon.length > 0 ? 54 : 16 })
                }
                TableCell(row, () => this.onRow(s, r))
              }, (row: TableRow, r: number) => s + '-' + r + '-' + row.key + row.title + row.checked)
            }
            .borderRadius(10)
            .clip(true)
            .margin({ left: 16, right: 16 })
            if (section.footer.length > 0) {
              SectionFooter(section.footer)
            }
          }
        }
      }, (section: TableSection, s: number) => s + section.title + section.rows.length)
      ListItem() {
        Column().height(24)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(UiColor.groupedBackground)
  }
}

@Builder
export function EmptyHeader() {
}
