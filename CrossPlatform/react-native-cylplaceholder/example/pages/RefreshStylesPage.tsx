import React, {useCallback, useState} from 'react';
import {FlatList, Pressable, StyleSheet, Text, View} from 'react-native';
import {CYLRefreshContainer, isCYLRefreshContainerAvailable, type CYLRefreshRiveOptions} from 'react-native-cylplaceholder';

const PAGE = 10;
const LAST_PAGE = 3;
const START_ROWS = 10;
const STYLES = ['classic', 'cupertino', 'material', 'bezierRadar', 'bezierCircle', 'delivery', 'phoenix', 'taurus', 'rive'];

/**
 * [EN] The `rive` style's parameters: flutter_easy_refresh's Bow file (MIT, credits in the Flutter example's `assets/animations/NOTICE.animations`),
 *      which the app target carries as a resource, driven by the names of its state machine (the same names as `CYLRefreshStylesDemoViewController`).
 * [CN] `rive` 样式的参数：flutter_easy_refresh 的 Bow 文件（MIT，来源见 Flutter 示例的 `assets/animations/NOTICE.animations`），由应用 target 作为资源携带，
 *      按其状态机的名称驱动（与 `CYLRefreshStylesDemoViewController` 的名称相同）。
 */
const RIVE: CYLRefreshRiveOptions = {
  riveFile: 'CYLScenarioExampleRefreshBow',
  riveStateMachine: 'numberSimulation',
  riveTriggerOffset: 200,
  riveFitsWidth: true,
  rivePullInput: 'pull',
  rivePullInputMinimum: 10,
  riveReleaseTrigger: 'advance',
  riveFinishTrigger: 'advance',
  riveRestartTrigger: 'restart',
  // The Bow file's drawn-height table (docs/Refresh-Library-Parity.md, "Rive drawn-height table"): the header is clipped to what the file draws at each pull input.
  riveDrawnTable: [[30, 0], [31.8, 0.14], [35.9, 0.43], [39.8, 0.66], [43.6, 0.82], [47.3, 0.94], [50, 1]],
};

const range = (from: number, count: number) => Array.from({length: count}, (_, i) => from + i + 1);

/**
 * [EN] The styles page of the Flutter example for iOS: chips choose the look of the native header and footer
 *      (`headerStyle` / `footerStyle`). It starts with one page that fits the screen: pull down to refresh (page 1 again), pull up twice to load pages 2 and 3,
 *      after which the footer says "no more data". "Reset" brings the first page back. On iOS the Cupertino footer is the auto footer
 *      (it loads on reaching the bottom, no pull), and Bezier circle has no drawn footer (the classic one shows).
 * [CN] Flutter 示例中样式页在 iOS 上的对应：用标签选择原生刷新头与刷新尾的样式（`headerStyle` / `footerStyle`）。
 *      起初只有一页（不超出屏幕）：下拉刷新（回到第 1 页），上拉两次加载第 2、3 页，之后刷新尾显示“没有更多数据”。“Reset” 恢复第一页与加载状态。
 */
export default function RefreshStylesPage() {
  const [style, setStyle] = useState('classic');
  const [rows, setRows] = useState<number[]>(range(0, START_ROWS));
  const [refreshing, setRefreshing] = useState(false);
  const [loadingMore, setLoadingMore] = useState(false);

  const refresh = useCallback(() => {
    setRefreshing(true);
    setTimeout(() => {
      setRows(range(0, START_ROWS));
      setRefreshing(false);
    }, 4000);
  }, []);

  const loadMore = useCallback(() => {
    setLoadingMore(true);
    setTimeout(() => {
      setRows(current => [...current, ...range(current.length, PAGE)]);
      setLoadingMore(false);
    }, 4000);
  }, []);

  const reset = useCallback(() => setRows(range(0, START_ROWS)), []);

  if (!isCYLRefreshContainerAvailable()) {
    return (
      <View style={styles.screen}>
        <Text style={styles.title}>No native CYLRefreshContainer in this build</Text>
      </View>
    );
  }

  return (
    <View style={styles.screen}>
      <Text style={styles.title}>{`Refresh styles: ${style}`}</Text>
      <View style={styles.chips}>
          {STYLES.map(name => (
            <Pressable
              key={name}
              accessibilityRole="button"
              accessibilityLabel={`style ${name}`}
              style={[styles.chip, name === style && styles.chipOn]}
              onPress={() => setStyle(name)}>
              <Text style={name === style ? styles.chipTextOn : undefined}>{name}</Text>
            </Pressable>
          ))}
          <Pressable accessibilityRole="button" accessibilityLabel="reset rows" style={styles.chip} onPress={reset}>
            <Text>Reset</Text>
          </Pressable>
      </View>
      <CYLRefreshContainer
        headerStyle={style}
        footerStyle={style}
        headerRive={style === 'rive' ? RIVE : undefined}
        footerRive={style === 'rive' ? RIVE : undefined}
        refreshing={refreshing}
        onRefresh={refresh}
        loadMoreEnabled
        loadingMore={loadingMore}
        noMoreData={rows.length / PAGE >= LAST_PAGE}
        onLoadMore={loadMore}>
        <FlatList
          style={styles.list}
          data={rows}
          keyExtractor={n => String(n)}
          renderItem={({item}) => (
            <View style={styles.row}>
              <Text>{`Row ${item}`}</Text>
            </View>
          )}
        />
      </CYLRefreshContainer>
    </View>
  );
}

const styles = StyleSheet.create({
  screen: {flex: 1, backgroundColor: '#fff'},
  title: {fontSize: 20, fontWeight: '600', padding: 16},
  chips: {flexDirection: 'row', flexWrap: 'wrap', paddingHorizontal: 12, paddingBottom: 4},
  chip: {paddingHorizontal: 12, paddingVertical: 6, marginRight: 8, marginBottom: 6, borderRadius: 16, borderWidth: 1, borderColor: '#999'},
  chipOn: {backgroundColor: '#0a58ca', borderColor: '#0a58ca'},
  chipTextOn: {color: '#fff'},
  list: {backgroundColor: '#fff'},
  row: {padding: 16, borderBottomWidth: StyleSheet.hairlineWidth, borderColor: '#ccc'},
});
