// A read-only, monospaced view of a raw text file of the example (the "File" page of CYLConfigurationViewController
// and the "Sources" page of the animation list): a non-editable UITextView with a 12 pt monospaced font.
// param.value: the rawfile path; param.title: the title (default: the file name). An unreadable file shows nothing.
import { readRawText } from '../common/RawFile';
import { RouteParam } from '../common/Routes';
import { NavTitle } from '../common/Ui';

@Component
export struct TextFilePage {
  param: RouteParam = new RouteParam();
  @State text: string = '';

  aboutToAppear(): void {
    this.text = readRawText(this.getUIContext(), this.param.value);
  }

  @Builder
  navTitle() {
    NavTitle(this.param.title.length > 0 ? this.param.title : this.param.value.replace(/^.*\//, ''))
  }

  build() {
    NavDestination() {
      Scroll() {
        Text(this.text)
          .fontSize(12)
          .lineHeight(17)
          .fontFamily('monospace')
          .copyOption(CopyOptions.LocalDevice)
          .width('100%')
          .padding(8)
      }
      .align(Alignment.TopStart)
      .width('100%')
      .height('100%')
    }
    .title(this.navTitle)
    .backgroundColor(Color.White)
  }
}
