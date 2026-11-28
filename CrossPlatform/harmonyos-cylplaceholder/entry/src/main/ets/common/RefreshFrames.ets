// The example's GIF frames (iOS example CYLRefreshFrames.images(ofBundledGIF:) in CYLRefreshIconListViewController):
// the core refresh GIFs cut into frames, so frame-driven controls ("animated images") show the frame that matches the
// pull and play the frames while refreshing. ImageKit decodes asynchronously, so the frames are loaded once when the
// Refresh tab appears; until then (or when decoding fails) a page gets the whole GIF, which plays by itself.
import { image } from '@kit.ImageKit';
import { CYLRefreshImage } from 'cylplaceholder';

const FOLDER: string = 'example/core-animations/';
const frames: Map<string, image.PixelMap[]> = new Map();
const loading: Set<string> = new Set();

/** Decodes a core refresh GIF into frames once (no-op when loaded or loading). */
export async function loadBundledGIFFrames(name: string, context: Context | null): Promise<void> {
  if (frames.has(name) || loading.has(name)) {
    return;
  }
  loading.add(name);
  try {
    if (context === null) {
      return;
    }
    const bytes = await context.resourceManager.getRawFileContent(FOLDER + name);
    const source = image.createImageSource(bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength));
    try {
      const maps = await source.createPixelMapList();
      if (maps.length > 0) {
        frames.set(name, maps);
      }
    } finally {
      source.release();
    }
  } catch (e) {
    // Keeps the whole-GIF fallback.
  } finally {
    loading.delete(name);
  }
}

/** The frames of a core refresh GIF, or the GIF itself while they are not decoded. */
export function imagesOfBundledGIF(name: string): CYLRefreshImage[] {
  const decoded = frames.get(name);
  if (decoded !== undefined) {
    return decoded;
  }
  return [$rawfile(FOLDER + name)];
}

/** Loads the frames the Refresh tab's pages use. */
export function preloadRefreshFrames(context: Context | null): Promise<void[]> {
  return Promise.all([loadBundledGIFFrames('CYLRefreshArrows.gif', context),
    loadBundledGIFFrames('CYLRefreshRing.gif', context)]);
}
