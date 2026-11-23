import React, {useCallback, useRef, useState} from 'react';
import {FlatList, StyleSheet, Text, View} from 'react-native';
import {
  CYLPlaceholderStyle,
  CYLPlaceholderView,
  CYLRefreshContainer,
} from 'react-native-cylplaceholder';

/**
 * [EN] Error placeholder page (Flutter's `error_placeholder_page.dart`): the first load fails and shows `CYLPlaceholderView`
 *      (error style); a tap on it, or a pull, retries. The second attempt succeeds.
 * [CN] 错误占位页（Flutter 的 `error_placeholder_page.dart`）：第一次加载失败，显示 `CYLPlaceholderView`（错误样式）；
 *      点击占位图或下拉即重试，第二次成功。
 */
export default function ErrorPlaceholderPage() {
  const [rows, setRows] = useState<number[]>([]);
  const [failed, setFailed] = useState(false);
  const [loading, setLoading] = useState(false);
  const [attempts, setAttempts] = useState(0);
  const count = useRef(0);

  const load = useCallback(() => {
    count.current += 1;
    const ok = count.current >= 2;
    setLoading(true);
    setAttempts(count.current);
    setTimeout(() => {
      setFailed(!ok);
      setRows(ok ? Array.from({length: 10}, (_, i) => i + 1) : []);
      setLoading(false);
    }, 1200);
  }, []);

  return (
    <View style={styles.screen}>
      <Text style={styles.title}>{`Error placeholder (attempts: ${attempts})`}</Text>
      <CYLRefreshContainer refreshing={loading} onRefresh={load}>
        <FlatList
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
              style={failed ? CYLPlaceholderStyle.error : CYLPlaceholderStyle.empty}
              title={failed ? 'Loading failed' : 'Nothing here yet'}
              message={failed ? 'Tap to retry.' : 'Tap or pull down to load.'}
              tapHandler={load}
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
