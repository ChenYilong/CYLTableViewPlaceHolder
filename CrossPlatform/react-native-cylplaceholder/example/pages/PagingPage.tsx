import React, {useMemo, useState, useSyncExternalStore} from 'react';
import {FlatList, StyleSheet, Text, View} from 'react-native';
import {
  CYLPlaceholderStyle,
  CYLPlaceholderView,
  CYLRefreshContainer,
  CYLRefreshPaging,
} from 'react-native-cylplaceholder';

const PAGE = 10;
const TOTAL_PAGES = 3;

/**
 * [EN] Paging page (Flutter's `paging_page.dart`): `CYLRefreshPaging` loads the pages and decides "no more data"; the native
 *      `CYLRefreshContainer` draws the header and footer. The pager has no JavaScript header or footer here: the container
 *      is the pull, the pager is the data.
 * [CN] 分页页（Flutter 的 `paging_page.dart`）：`CYLRefreshPaging` 负责加载页和判断“没有更多数据”；原生
 *      `CYLRefreshContainer` 绘制头部和尾部。这里的分页器没有 JavaScript 头尾：容器负责下拉，分页器负责数据。
 */
export default function PagingPage() {
  const [busy, setBusy] = useState<'refresh' | 'more' | null>(null);
  const paging = useMemo(
    () =>
      new CYLRefreshPaging<number>({
        loader: (page, completion) => {
          setTimeout(() => {
            completion(Array.from({length: PAGE}, (_, i) => (page - 1) * PAGE + i + 1), {totalPage: TOTAL_PAGES});
            setBusy(null);
          }, 1500);
        },
      }),
    [],
  );
  useSyncExternalStore(paging.subscribe.bind(paging), () => paging.version);
  const items = paging.items ?? [];

  return (
    <View style={styles.screen}>
      <Text style={styles.title}>{`Paging: page ${paging.page} of ${TOTAL_PAGES}, ${paging.count} rows`}</Text>
      <CYLRefreshContainer
        refreshing={busy === 'refresh'}
        onRefresh={() => {
          setBusy('refresh');
          paging.refresh();
        }}
        loadMoreEnabled={items.length > 0}
        loadingMore={busy === 'more'}
        noMoreData={paging.isNoMore}
        onLoadMore={() => {
          setBusy('more');
          paging.loadMore();
        }}>
        <FlatList
          style={styles.list}
          data={items}
          keyExtractor={n => String(n)}
          renderItem={({item}) => (
            <View style={styles.row}>
              <Text>{`Row ${item}`}</Text>
            </View>
          )}
          contentContainerStyle={items.length === 0 ? styles.empty : undefined}
          ListEmptyComponent={
            <CYLPlaceholderView
              style={CYLPlaceholderStyle.empty}
              title="Nothing here yet"
              message="Pull down to load the first page."
            />
          }
        />
      </CYLRefreshContainer>
    </View>
  );
}

const styles = StyleSheet.create({
  screen: {flex: 1, backgroundColor: '#fff'},
  title: {fontSize: 18, fontWeight: '600', padding: 16},
  list: {backgroundColor: '#fff'},
  row: {padding: 16, borderBottomWidth: StyleSheet.hairlineWidth, borderColor: '#ccc'},
  empty: {flexGrow: 1, justifyContent: 'center'},
});
