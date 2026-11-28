// The bundled icons (rawfile/cylplaceholder/images), as Resources. $rawfile() only accepts a string literal, so
// every icon is listed here; regenerate this list when icons are added.
const IMAGES: Record<string, Resource> = {
  'archive': $rawfile('cylplaceholder/images/archive.png'),
  'battery_alert': $rawfile('cylplaceholder/images/battery_alert.png'),
  'blocked': $rawfile('cylplaceholder/images/blocked.png'),
  'bluetooth_disabled': $rawfile('cylplaceholder/images/bluetooth_disabled.png'),
  'broken_image': $rawfile('cylplaceholder/images/broken_image.png'),
  'cloud': $rawfile('cylplaceholder/images/cloud.png'),
  'cloud_off': $rawfile('cylplaceholder/images/cloud_off.png'),
  'delete': $rawfile('cylplaceholder/images/delete.png'),
  'download_off': $rawfile('cylplaceholder/images/download_off.png'),
  'empty': $rawfile('cylplaceholder/images/empty.png'),
  'empty_cart': $rawfile('cylplaceholder/images/empty_cart.png'),
  'error': $rawfile('cylplaceholder/images/error.png'),
  'error_outline': $rawfile('cylplaceholder/images/error_outline.png'),
  'event_busy': $rawfile('cylplaceholder/images/event_busy.png'),
  'favorite': $rawfile('cylplaceholder/images/favorite.png'),
  'folder_off': $rawfile('cylplaceholder/images/folder_off.png'),
  'folder_open': $rawfile('cylplaceholder/images/folder_open.png'),
  'group_off': $rawfile('cylplaceholder/images/group_off.png'),
  'help': $rawfile('cylplaceholder/images/help.png'),
  'history': $rawfile('cylplaceholder/images/history.png'),
  'hourglass': $rawfile('cylplaceholder/images/hourglass.png'),
  'image': $rawfile('cylplaceholder/images/image.png'),
  'image_unavailable': $rawfile('cylplaceholder/images/image_unavailable.png'),
  'inbox': $rawfile('cylplaceholder/images/inbox.png'),
  'info': $rawfile('cylplaceholder/images/info.png'),
  'check_circle': $rawfile('cylplaceholder/images/check_circle.png'),
  'location_off': $rawfile('cylplaceholder/images/location_off.png'),
  'locked': $rawfile('cylplaceholder/images/locked.png'),
  'mail': $rawfile('cylplaceholder/images/mail.png'),
  'music_off': $rawfile('cylplaceholder/images/music_off.png'),
  'network_locked': $rawfile('cylplaceholder/images/network_locked.png'),
  'no_internet': $rawfile('cylplaceholder/images/no_internet.png'),
  'no_results': $rawfile('cylplaceholder/images/no_results.png'),
  'notifications_off': $rawfile('cylplaceholder/images/notifications_off.png'),
  'person_off': $rawfile('cylplaceholder/images/person_off.png'),
  'phone_disabled': $rawfile('cylplaceholder/images/phone_disabled.png'),
  'photo_library': $rawfile('cylplaceholder/images/photo_library.png'),
  'public_off': $rawfile('cylplaceholder/images/public_off.png'),
  'refresh': $rawfile('cylplaceholder/images/refresh.png'),
  'report_problem': $rawfile('cylplaceholder/images/report_problem.png'),
  'search': $rawfile('cylplaceholder/images/search.png'),
  'search_off': $rawfile('cylplaceholder/images/search_off.png'),
  'signal_wifi_off': $rawfile('cylplaceholder/images/signal_wifi_off.png'),
  'status_fail': $rawfile('cylplaceholder/images/status_fail.png'),
  'sync_disabled': $rawfile('cylplaceholder/images/sync_disabled.png'),
  'sync_problem': $rawfile('cylplaceholder/images/sync_problem.png'),
  'unknown_device': $rawfile('cylplaceholder/images/unknown_device.png'),
  'upload_off': $rawfile('cylplaceholder/images/upload_off.png'),
  'video_off': $rawfile('cylplaceholder/images/video_off.png'),
  'visibility_off': $rawfile('cylplaceholder/images/visibility_off.png'),
  'warning': $rawfile('cylplaceholder/images/warning.png'),
  'wifi_off': $rawfile('cylplaceholder/images/wifi_off.png'),
  'wrong_location': $rawfile('cylplaceholder/images/wrong_location.png')
};

/** The names of the bundled icons ("wifi_off", "empty", ...). */
export const CYLPlaceholderImageNames: string[] = Object.keys(IMAGES);

/** The bundled icon called name ("wifi_off"), or null. */
export function CYLPlaceholderImageResource(name: string): Resource | null {
  const found: Resource | undefined = IMAGES[name];
  return found !== undefined ? found : null;
}

/** The bundled animation files (rawfile/cylplaceholder/animations). */
export const CYLPlaceholderBundledAnimationFileNames: string[] = [
  'CYLPlaceholderBluetoothPermission.json',
  'CYLPlaceholderCalendarPermission.json',
  'CYLPlaceholderCameraPermission.json',
  'CYLPlaceholderCelebrate.json',
  'CYLPlaceholderCloudOff.json',
  'CYLPlaceholderContactSupport.json',
  'CYLPlaceholderContactsPermission.json',
  'CYLPlaceholderEmpty.json',
  'CYLPlaceholderEmptyCart.json',
  'CYLPlaceholderLoadFailed.json',
  'CYLPlaceholderLoading.json',
  'CYLPlaceholderLoading.pag',
  'CYLPlaceholderLoading.riv',
  'CYLPlaceholderLoadingInfinity.json',
  'CYLPlaceholderLocation.json',
  'CYLPlaceholderLocationPermission.json',
  'CYLPlaceholderMicrophonePermission.json',
  'CYLPlaceholderNoDrafts.json',
  'CYLPlaceholderNoFavorites.gif',
  'CYLPlaceholderNoFavorites.json',
  'CYLPlaceholderNoFavorites.pag',
  'CYLPlaceholderNoInternet.json',
  'CYLPlaceholderNoMessages.json',
  'CYLPlaceholderNoNotifications.json',
  'CYLPlaceholderNoOrders.json',
  'CYLPlaceholderNoPermission.json',
  'CYLPlaceholderNoResults.json',
  'CYLPlaceholderNotificationPermission.json',
  'CYLPlaceholderPhotoLibraryPermission.json',
  'CYLPlaceholderProgress.pag',
  'CYLPlaceholderPullHint.pag',
  'CYLPlaceholderPullToRefresh.riv',
  'CYLPlaceholderRefresh.json',
  'CYLPlaceholderSad.json',
  'CYLPlaceholderServerError.json',
  'CYLPlaceholderSettings.json',
  'CYLPlaceholderSuccess.json',
  'CYLPlaceholderSuccess.riv',
  'CYLPlaceholderTapHint.json',
  'CYLPlaceholderUploading.gif',
  'CYLRefreshActivity.gif',
  'CYLRefreshDoneCircle.json'
];

/** What a CYLPlaceholderImageBundle reads images from: a ResourceManager (of any module or HAR context). */
export interface CYLPlaceholderImageResourceManager {
  getMediaBase64ByNameSync(resName: string): string;
}

/**
 * Where image names in item attributes are looked up (iOS `NSBundle *imageBundle`): the media (resources/base/media)
 * of a resource manager, such as `context.createModuleContext('feature').resourceManager` of another module or HAR,
 * or a lookup of your own. null in the APIs that take one uses the library's bundled icons.
 */
export class CYLPlaceholderImageBundle {
  private lookup: (name: string) => ResourceStr | null;

  private constructor(lookup: (name: string) => ResourceStr | null) {
    this.lookup = lookup;
  }

  /** The media of a resource manager: "empty_box" names resources/base/media/empty_box.png, drawn as a data URL. */
  static bundleWithResourceManager(manager: CYLPlaceholderImageResourceManager): CYLPlaceholderImageBundle {
    return new CYLPlaceholderImageBundle((name: string) => {
      try {
        const data = manager.getMediaBase64ByNameSync(name);
        return data.length > 0 ? data : null;
      } catch (e) {
        return null;
      }
    });
  }

  /** A bundle whose images come from `lookup` (null: not found). */
  static bundleWithLookup(lookup: (name: string) => ResourceStr | null): CYLPlaceholderImageBundle {
    return new CYLPlaceholderImageBundle(lookup);
  }

  /** The image called name, or null when the bundle has none (iOS `+imageNamed:inBundle:`). */
  imageNamed(name: string): ResourceStr | null {
    return name.length > 0 ? this.lookup(name) : null;
  }
}

/**
 * The image an attribute value names: a Resource stays as it is; a name is looked up in `bundle` (null when it has
 * none, as iOS fails), or without a bundle is a bundled icon, else a path.
 */
export function CYLPlaceholderResolveImage(value: ResourceStr | null, bundle: CYLPlaceholderImageBundle | null): ResourceStr | null {
  if (value === null || typeof value !== 'string') {
    return value;
  }
  if (bundle !== null) {
    return bundle.imageNamed(value as string);
  }
  const bundled = CYLPlaceholderImageResource(value as string);
  return bundled !== null ? bundled : value;
}
