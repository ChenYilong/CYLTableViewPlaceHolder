import React, {useEffect, useState} from 'react';
import {BackHandler, Pressable, SafeAreaView, StyleSheet, Text, View} from 'react-native';
import {isCYLRefreshContainerAvailable} from 'react-native-cylplaceholder';
import ErrorPlaceholderPage from './pages/ErrorPlaceholderPage';
import HUDPage from './pages/HUDPage';
import PagingPage from './pages/PagingPage';
import PlaceholderStackPage from './pages/PlaceholderStackPage';
import RefreshPage from './pages/RefreshPage';

/**
 * [EN] The demo menu: the pages of the Flutter example (`refresh_page`, `paging_page`, `error_placeholder_page`,
 *      `placeholder_stack_page`) that this package's native components can show on Android, and a HUD page. The styles and
 *      second floor pages are not here (see README).
 * [CN] 示例菜单：Flutter 示例中此包的原生组件在 Android 上能展示的页面，以及 HUD 页。样式页和二楼页不在这里（见 README）。
 */
const PAGES = [
  {key: 'refresh', title: 'Refresh (refresh_page)', Page: RefreshPage},
  {key: 'paging', title: 'Paging (paging_page)', Page: PagingPage},
  {key: 'error', title: 'Error placeholder (error_placeholder_page)', Page: ErrorPlaceholderPage},
  {key: 'stack', title: 'Placeholder stack (placeholder_stack_page)', Page: PlaceholderStackPage},
  {key: 'hud', title: 'HUD', Page: HUDPage},
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
