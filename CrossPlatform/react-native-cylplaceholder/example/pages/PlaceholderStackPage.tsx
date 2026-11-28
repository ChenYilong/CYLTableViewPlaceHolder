import React, {useMemo, useState} from 'react';
import {Pressable, StyleSheet, Switch, Text, View} from 'react-native';
import {
  CYLPlaceholderComponent,
  CYLPlaceholderStack,
  CYLPlaceholderStyle,
  isCYLPlaceholderStackAvailable,
} from 'react-native-cylplaceholder';

/**
 * [EN] Placeholder stack page (Flutter's `placeholder_stack_page.dart`): the native `CYLPlaceholderStackView` from a component
 *      list, with the playback controls every animation page has: "Play all" restarts the animations from the start, the speed
 *      buttons and the loop switch apply live; a tapped button comes back as `onAction`.
 * [CN] 占位 stack 页（Flutter 的 `placeholder_stack_page.dart`）：由组件列表生成原生 `CYLPlaceholderStackView`，带动画页都有的播放控制：
 *      “Play all” 从头重播，速度按钮与循环开关即时生效；按钮点击经 `onAction` 回传。
 */
export default function PlaceholderStackPage() {
  const [speed, setSpeed] = useState(1);
  const [loops, setLoops] = useState(false);
  const [token, setToken] = useState(0);
  const [lastAction, setLastAction] = useState('none');

  const components = useMemo(
    () => [
      CYLPlaceholderComponent.icon({
        style: CYLPlaceholderStyle.cloudOff,
        title: 'Something went wrong',
        animation: 'CYLPlaceholderLoadFailed.json',
        animationLoops: loops,
        animationSpeed: speed,
      }),
      CYLPlaceholderComponent.hint('Check your connection and try again'),
      CYLPlaceholderComponent.button('Retry', 'retry'),
      CYLPlaceholderComponent.separator('or'),
      CYLPlaceholderComponent.button('Contact support', 'support', {buttonStyle: 'outlined'}),
    ],
    [loops, speed],
  );

  if (!isCYLPlaceholderStackAvailable()) {
    return <Text style={styles.title}>No native CYLPlaceholderStack in this build</Text>;
  }
  return (
    <View style={styles.screen}>
      <Text style={styles.title}>{`Placeholder stack (last action: ${lastAction})`}</Text>
      <CYLPlaceholderStack components={components} restartToken={token} onAction={setLastAction} />
      <View style={styles.controls}>
        <Pressable accessibilityRole="button" style={styles.play} onPress={() => setToken(t => t + 1)}>
          <Text style={styles.playText}>Play all</Text>
        </Pressable>
        {[0.5, 1, 2].map(s => (
          <Pressable
            key={s}
            accessibilityRole="button"
            accessibilityState={{selected: speed === s}}
            style={[styles.speed, speed === s && styles.speedOn]}
            onPress={() => setSpeed(s)}>
            <Text>{`${s}x`}</Text>
          </Pressable>
        ))}
        <Text>Loop</Text>
        <Switch value={loops} onValueChange={setLoops} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  screen: {flex: 1},
  title: {fontSize: 16, fontWeight: '600', padding: 12},
  controls: {flexDirection: 'row', alignItems: 'center', gap: 8, padding: 12},
  play: {backgroundColor: '#0a58ca', borderRadius: 6, paddingHorizontal: 14, paddingVertical: 8},
  playText: {color: '#fff', fontWeight: '600'},
  speed: {borderWidth: 1, borderColor: '#999', borderRadius: 6, paddingHorizontal: 10, paddingVertical: 6},
  speedOn: {backgroundColor: '#dbe7ff', borderColor: '#0a58ca'},
});
