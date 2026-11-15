// Frame images of the refresh controls: a resource / path, or a decoded frame (PixelMap), as iOS takes any UIImage
// (the iOS example cuts GIFs into frames with ImageIO; the HarmonyOS example does it with ImageKit).
import { image } from '@kit.ImageKit';

/** One frame of a refresh control's images. */
export type CYLRefreshImage = ResourceStr | image.PixelMap;
