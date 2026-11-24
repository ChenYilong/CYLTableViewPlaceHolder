import React, {useCallback, useState} from 'react';
import {FlatList, Pressable, StyleSheet, Text, View} from 'react-native';
import {CYLRefreshContainer, isCYLRefreshContainerAvailable} from 'react-native-cylplaceholder';

const TRIGGER = 120;

/**
 * [EN] The second floor (secondary_page of the Flutter example) on iOS: a pull past `secondaryTriggerOffset` opens the floor and
 *      calls `onSecondaryOpen`; a push back (or the button) closes it. `secondaryOpen` is the state JavaScript owns, set from the
 *      two events as `refreshing` is set from `onRefresh`. "Unmount" removes the container while the floor is open, to check that
 *      the floor view (re-parented by the native header) does not crash the unmount. The counters show what reached JavaScript.
 * [CN] 二楼（Flutter 示例的 secondary_page）在 iOS 上的对应：下拉超过 `secondaryTriggerOffset` 后松手打开二楼并调用
 *      `onSecondaryOpen`；上推（或按钮）关闭。`secondaryOpen` 是 JavaScript 持有的状态，由两个事件设置，就像 `refreshing` 由
 *      `onRefresh` 设置。“Unmount” 在二楼打开时移除容器，检查被原生头重新挂接的二楼视图不会使卸载崩溃。计数器显示到达 JavaScript 的事件。
 */
export default function SecondFloorPage() {
  const [open, setOpen] = useState(false);
  const [opened, setOpened] = useState(0);
  const [closed, setClosed] = useState(0);
  const [refreshes, setRefreshes] = useState(0);
  const [refreshing, setRefreshing] = useState(false);
  const [mounted, setMounted] = useState(true);

  const onOpen = useCallback(() => {
    setOpen(true);
    setOpened(n => n + 1);
  }, []);
  const onClose = useCallback(() => {
    setOpen(false);
    setClosed(n => n + 1);
  }, []);
  const onRefresh = useCallback(() => {
    setRefreshing(true);
    setRefreshes(n => n + 1);
    setTimeout(() => setRefreshing(false), 1500);
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
      <Text style={styles.title}>Second floor</Text>
      <Text accessibilityLabel="floor status" style={styles.status}>
        {`floor ${open ? 'open' : 'closed'} | onSecondaryOpen ${opened} | onSecondaryClose ${closed} | onRefresh ${refreshes}`}
      </Text>
      <View style={styles.buttons}>
        <Pressable accessibilityRole="button" accessibilityLabel="open floor" style={styles.button} onPress={() => setOpen(true)}>
          <Text>Open</Text>
        </Pressable>
        <Pressable accessibilityRole="button" accessibilityLabel="close floor" style={styles.button} onPress={() => setOpen(false)}>
          <Text>Close</Text>
        </Pressable>
        <Pressable accessibilityRole="button" accessibilityLabel="unmount container" style={styles.button} onPress={() => setMounted(false)}>
          <Text>Unmount</Text>
        </Pressable>
        <Pressable accessibilityRole="button" accessibilityLabel="mount container" style={styles.button} onPress={() => setMounted(true)}>
          <Text>Mount</Text>
        </Pressable>
      </View>
      {mounted ? (
        <CYLRefreshContainer
          refreshing={refreshing}
          onRefresh={onRefresh}
          secondaryTriggerOffset={TRIGGER}
          secondaryOpen={open}
          onSecondaryOpen={onOpen}
          onSecondaryClose={onClose}>
          <View nativeID="cyl.refresh.secondary" style={styles.floor}>
            <Text accessibilityLabel="second floor content" style={styles.floorText}>Welcome to the second floor</Text>
          </View>
          <FlatList
            style={styles.list}
            data={Array.from({length: 30}, (_, i) => i + 1)}
            keyExtractor={n => String(n)}
            renderItem={({item}) => (
              <View style={styles.row}>
                <Text>{`Row ${item}`}</Text>
              </View>
            )}
          />
        </CYLRefreshContainer>
      ) : (
        <Text accessibilityLabel="container unmounted" style={styles.status}>Container unmounted: no crash. Tap Mount.</Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  screen: {flex: 1, backgroundColor: '#fff'},
  title: {fontSize: 20, fontWeight: '600', padding: 16},
  status: {paddingHorizontal: 16, paddingBottom: 8},
  buttons: {flexDirection: 'row', paddingHorizontal: 12, paddingBottom: 8},
  button: {paddingHorizontal: 12, paddingVertical: 6, marginRight: 8, borderRadius: 16, borderWidth: 1, borderColor: '#999'},
  // [EN] The native header sets the floor's frame; the height here only lays out its content.
  // [CN] 二楼视图的 frame 由原生头设置；这里的高度只用于排布其内容。
  floor: {position: 'absolute', left: 0, top: 0, width: 400, height: 700, backgroundColor: '#2e7d32', paddingTop: 300},
  floorText: {color: '#fff', fontSize: 22, fontWeight: '600', textAlign: 'center'},
  list: {backgroundColor: '#fff'},
  row: {padding: 16, borderBottomWidth: StyleSheet.hairlineWidth, borderColor: '#ccc'},
});
