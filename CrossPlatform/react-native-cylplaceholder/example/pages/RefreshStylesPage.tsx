import React, {useCallback, useState} from 'react';
import {FlatList, Pressable, ScrollView, StyleSheet, Text, View} from 'react-native';
import {CYLRefreshContainer, isCYLRefreshContainerAvailable} from 'react-native-cylplaceholder';

const PAGE = 10;
const LAST_PAGE = 3;
const START_ROWS = 20;
const STYLES = ['classic', 'cupertino', 'material', 'bezierRadar', 'bezierCircle', 'delivery', 'phoenix', 'taurus'];

const range = (from: number, count: number) => Array.from({length: count}, (_, i) => from + i + 1);

/**
 * [EN] The styles page of the Flutter example for iOS: chips choose the look of the native header and footer
 *      (`headerStyle` / `footerStyle`). It starts with two pages: pull down to refresh (page 1 again), pull up to load page 3,
 *      after which the footer says "no more data". "Reset" brings the two pages back. On iOS the Cupertino footer is the auto footer
 *      (it loads on reaching the bottom, no pull), and Bezier circle has no drawn footer (the classic one shows).
 * [CN] Flutter 示例中样式页在 iOS 上的对应：用标签选择原生刷新头与刷新尾的样式（`headerStyle` / `footerStyle`）。
 *      起初有两页：下拉刷新（回到第 1 页），上拉加载第 3 页，之后刷新尾显示“没有更多数据”。“Reset” 恢复两页与加载状态。
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
    }, 2500);
  }, []);

  const loadMore = useCallback(() => {
    setLoadingMore(true);
    setTimeout(() => {
      setRows(current => [...current, ...range(current.length, PAGE)]);
      setLoadingMore(false);
    }, 2500);
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
      <View>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.chips}>
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
        </ScrollView>
      </View>
      <CYLRefreshContainer
        headerStyle={style}
        footerStyle={style}
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
  chips: {paddingHorizontal: 12, paddingBottom: 8},
  chip: {paddingHorizontal: 12, paddingVertical: 6, marginRight: 8, borderRadius: 16, borderWidth: 1, borderColor: '#999'},
  chipOn: {backgroundColor: '#0a58ca', borderColor: '#0a58ca'},
  chipTextOn: {color: '#fff'},
  list: {backgroundColor: '#fff'},
  row: {padding: 16, borderBottomWidth: StyleSheet.hairlineWidth, borderColor: '#ccc'},
});
