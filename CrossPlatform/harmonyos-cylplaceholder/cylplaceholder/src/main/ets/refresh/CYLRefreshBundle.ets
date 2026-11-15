// CYLRefreshBundle: the HarmonyOS counterpart of iOS NSBundle+CYLRefresh.h. The refresh images and bundled refresh
// animations are rawfiles under rawfile/cylplaceholder/refresh ($rawfile takes only literals, so they are listed).
import { CYLRefreshLocalizedString } from './CYLRefreshConst';

const BUNDLED_ANIMATIONS: Record<string, Resource> = {
  'CYLRefreshArrows.gif': $rawfile('cylplaceholder/refresh/CYLRefreshArrows.gif'),
  'CYLRefreshPullArrow.json': $rawfile('cylplaceholder/refresh/CYLRefreshPullArrow.json')
};

/** iOS `NSBundle (CYLRefresh)`. */
export class CYLRefreshBundle {
  /** The rawfile directory holding the refresh resources (`+cyl_refreshBundle`). */
  static cyl_refreshBundle(): string {
    return 'cylplaceholder/refresh';
  }

  /** The pull arrow (`+cyl_arrowImage`). */
  static cyl_arrowImage(): Resource {
    return $rawfile('cylplaceholder/refresh/CYLRefreshArrow@2x.png');
  }

  /** The trailer's arrow (`+cyl_trailArrowImage`). */
  static cyl_trailArrowImage(): Resource {
    return $rawfile('cylplaceholder/refresh/CYLRefreshTrailArrow@2x.png');
  }

  /** A refresh text, `value` when the key is missing (`+cyl_localizedStringForKey:value:`). */
  static cyl_localizedStringForKeyValue(key: string, value: string | null): string {
    return CYLRefreshLocalizedString(key, value);
  }

  /** A refresh text (`+cyl_localizedStringForKey:`). */
  static cyl_localizedStringForKey(key: string): string {
    return CYLRefreshLocalizedString(key, null);
  }

  /** The resource of an animation file path: a bundled refresh animation, else the path itself (a URI). */
  static animationSource(filePath: string): ResourceStr {
    const prefix = 'cylplaceholder/refresh/';
    const name = filePath.startsWith(prefix) ? filePath.substring(prefix.length) : filePath;
    const bundled: Resource | undefined = BUNDLED_ANIMATIONS[name];
    return bundled !== undefined ? bundled : filePath;
  }
}
