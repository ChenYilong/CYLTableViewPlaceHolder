import React, {useCallback, useState} from 'react';
import {FlatList, StyleSheet, Text, View} from 'react-native';
import {
  CYLPlaceholderStyle,
  CYLPlaceholderView,
  CYLRefreshContainer,
  isCYLRefreshContainerAvailable,
} from 'react-native-cylplaceholder';

const PAGE = 10;
const LAST_PAGE = 3;

/**
 * [EN] One screen: a list inside the native `CYLRefreshContainer`. It starts empty and shows the placeholder; pulling down
 *      loads page 1, pulling up loads the next page, after page 3 the footer says "no more data".
 * [CN] 一个页面：原生 `CYLRefreshContainer` 里放一个列表。起初为空并显示占位图；下拉加载第 1 页，上拉加载下一页，
 *      第 3 页之后尾部显示“没有更多数据”。
 */
export default function RefreshPage() {
  const [rows, setRows] = useState<number[]>([]);
  const [refreshing, setRefreshing] = useState(false);
  const [loadingMore, setLoadingMore] = useState(false);

  const pages = rows.length / PAGE;
  const range = (page: number) => Array.from({length: PAGE}, (_, i) => page * PAGE + i + 1);

  const refresh = useCallback(() => {
    setRefreshing(true);
    setTimeout(() => {
      setRows(range(0));
      setRefreshing(false);
    }, 1500);
  }, []);

  const loadMore = useCallback(() => {
    setLoadingMore(true);
    setTimeout(() => {
      setRows(current => [...current, ...range(current.length / PAGE)]);
      setLoadingMore(false);
    }, 1500);
  }, []);

  if (!isCYLRefreshContainerAvailable()) {
    return (
      <View style={styles.screen}>
        <Text style={styles.title}>No native CYLRefreshContainer in this build</Text>
      </View>
    );
  }

  return (
    <View style={styles.screen}>
      <Text style={styles.title}>Refresh</Text>
      <CYLRefreshContainer
        refreshing={refreshing}
        onRefresh={refresh}
        loadMoreEnabled={rows.length > 0}
        loadingMore={loadingMore}
        noMoreData={pages >= LAST_PAGE}
        onLoadMore={loadMore}>
        <FlatList
          // [EN] The native header sits behind the content, so the list needs its own background to cover it at rest.
          // [CN] 原生头部在内容后面，列表要有自己的背景，静止时才盖住它。
          style={styles.list}
          data={rows}
          keyExtractor={n => String(n)}
          renderItem={({item}) => (
            <View style={styles.row}>
              <Text>{`Row ${item}`}</Text>
            </View>
          )}
          contentContainerStyle={rows.length === 0 ? styles.empty : undefined}
          ListEmptyComponent={
            <CYLPlaceholderView
              style={CYLPlaceholderStyle.empty}
              title="Nothing here yet"
              message="Pull down to load the first page."
              tapHandler={refresh}
            />
          }
        />
      </CYLRefreshContainer>
    </View>
  );
}

const styles = StyleSheet.create({
  screen: {flex: 1, backgroundColor: '#fff'},
  title: {fontSize: 20, fontWeight: '600', padding: 16},
  list: {backgroundColor: '#fff'},
  row: {padding: 16, borderBottomWidth: StyleSheet.hairlineWidth, borderColor: '#ccc'},
  empty: {flexGrow: 1, justifyContent: 'center'},
});
