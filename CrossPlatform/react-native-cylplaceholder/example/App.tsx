import React, {useEffect, useState} from 'react';
import {BackHandler, Pressable, SafeAreaView, StyleSheet, Text, View} from 'react-native';
import {isCYLRefreshContainerAvailable} from 'react-native-cylplaceholder';
import ErrorPlaceholderPage from './pages/ErrorPlaceholderPage';
import PagingPage from './pages/PagingPage';
import RefreshPage from './pages/RefreshPage';

/**
 * [EN] The demo menu: the pages of the Flutter example (`refresh_page`, `paging_page`, `error_placeholder_page`) that this
 *      package's native container can show on Android. The styles, second floor and stack pages are not here (see README).
 * [CN] 示例菜单：Flutter 示例中此包的原生容器在 Android 上能展示的页面。样式页、二楼页和 stack 页不在这里（见 README）。
 */
const PAGES = [
  {key: 'refresh', title: 'Refresh (refresh_page)', Page: RefreshPage},
  {key: 'paging', title: 'Paging (paging_page)', Page: PagingPage},
  {key: 'error', title: 'Error placeholder (error_placeholder_page)', Page: ErrorPlaceholderPage},
];

export default function App() {
  const [current, setCurrent] = useState<string | null>(null);

  useEffect(() => {
    const subscription = BackHandler.addEventListener('hardwareBackPress', () => {
      if (current === null) return false;
      setCurrent(null);
      return true;
    });
    return () => subscription.remove();
  }, [current]);

  if (!isCYLRefreshContainerAvailable()) {
    return (
      <SafeAreaView style={styles.screen}>
        <Text style={styles.title}>No native CYLRefreshContainer in this build</Text>
      </SafeAreaView>
    );
  }

  const page = PAGES.find(p => p.key === current);
  return (
    <SafeAreaView style={styles.screen}>
      {page === undefined ? (
        <View>
          <Text style={styles.title}>CYLTableViewPlaceHolder demos</Text>
          {PAGES.map(p => (
            <Pressable key={p.key} accessibilityRole="button" style={styles.item} onPress={() => setCurrent(p.key)}>
              <Text style={styles.itemText}>{p.title}</Text>
            </Pressable>
          ))}
        </View>
      ) : (
        <>
          <Pressable accessibilityRole="button" onPress={() => setCurrent(null)}>
            <Text style={styles.back}>{'< Demos'}</Text>
          </Pressable>
          <page.Page />
        </>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  screen: {flex: 1, backgroundColor: '#fff'},
  title: {fontSize: 20, fontWeight: '600', padding: 16},
  item: {padding: 16, borderBottomWidth: StyleSheet.hairlineWidth, borderColor: '#ccc'},
  itemText: {fontSize: 16},
  back: {fontSize: 16, color: '#0a58ca', paddingHorizontal: 16, paddingTop: 8},
});
