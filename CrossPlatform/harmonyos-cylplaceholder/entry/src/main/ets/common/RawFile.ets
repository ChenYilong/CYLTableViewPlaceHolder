// Reads the example's bundled files (rawfile/example/..., the iOS CYLScenarioExample.bundle) as text.
import { util } from '@kit.ArkTS';

/** The UTF-8 text of a rawfile ("example/configurations/location-permission.json"), or '' when it cannot be read. */
export function readRawText(context: UIContext, path: string): string {
  try {
    const bytes = context.getHostContext()!.resourceManager.getRawFileContentSync(path);
    return util.TextDecoder.create('utf-8').decodeToString(bytes);
  } catch (e) {
    return '';
  }
}

/** The size in bytes of a rawfile, or 0 when it cannot be read. */
export function rawFileSize(context: UIContext, path: string): number {
  try {
    return context.getHostContext()!.resourceManager.getRawFileContentSync(path).length;
  } catch (e) {
    return 0;
  }
}

/** The names of the files in a rawfile directory, sorted. */
export function rawFileList(context: UIContext, directory: string): string[] {
  try {
    return context.getHostContext()!.resourceManager.getRawFileListSync(directory).sort();
  } catch (e) {
    return [];
  }
}
