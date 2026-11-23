/**
 * The ForEach key of a RefreshEasyPage row. The rows are plain objects (not @Observed), so ForEach re-runs a row's builder
 * only when its key changes: a key of the id alone left a row's new text (the scroll mode page's check mark, the trigger
 * mode page's counts) unrendered. The text is part of the key so a changed row is rebuilt.
 */
export function easyRowKey(id: string, text: string): string {
  return id + '|' + text;
}
