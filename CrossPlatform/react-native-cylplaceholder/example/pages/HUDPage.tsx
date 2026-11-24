import React, {useEffect, useMemo, useState} from 'react';
import {Pressable, StyleSheet, Text, View} from 'react-native';
import {CYLPlaceholderHUD, isCYLPlaceholderHUDAvailable} from 'react-native-cylplaceholder';

/**
 * [EN] HUD page: the native `CYLPlaceholderHUD` drawn over the activity, driven with the Flutter package's method names.
 * [CN] HUD 页：绘制在 Activity 之上的原生 `CYLPlaceholderHUD`，方法名与 Flutter 包一致。
 */
export default function HUDPage() {
  const hud = useMemo(() => new CYLPlaceholderHUD(), []);
  const [log, setLog] = useState('none');
  useEffect(() => () => {
    hud.dismiss();
    hud.dispose();
  }, [hud]);

  const progress = async () => {
    for (let i = 0; i <= 10; i++) {
      hud.showProgress(i / 10, 'Uploading');
      await new Promise(resolve => setTimeout(resolve, 150));
    }
    hud.showSuccessWithStatus('Uploaded');
  };
  const components = () =>
    hud.showComponents([
      {type: 'icon', style: 'warning', title: 'Custom HUD'},
      {type: 'hint', title: 'Shown with showComponents'},
      {type: 'button', title: 'OK', action: () => {
        setLog('OK tapped');
        hud.dismiss();
      }},
    ]);

  const buttons: Array<[string, () => void]> = [
    ['Show with status', () => {
      hud.showWithStatus('Please wait');
      hud.dismissWithDelay(2, () => setLog('dismissed after 2 s'));
    }],
    ['Show progress', progress],
    ['Success', () => hud.showSuccessWithStatus('Saved')],
    ['Error', () => hud.showErrorWithStatus('Could not save')],
    ['Info', () => hud.showInfoWithStatus('Pull down to refresh')],
    ['Components', components],
    ['Dismiss', () => hud.dismiss()],
  ];

  if (!isCYLPlaceholderHUDAvailable()) {
    return <Text style={styles.title}>No native CYLPlaceholderHUD in this build</Text>;
  }
  return (
    <View style={styles.screen}>
      <Text style={styles.title}>{`HUD (log: ${log})`}</Text>
      {buttons.map(([title, onPress]) => (
        <Pressable key={title} accessibilityRole="button" style={styles.button} onPress={onPress}>
          <Text style={styles.buttonText}>{title}</Text>
        </Pressable>
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  screen: {flex: 1},
  title: {fontSize: 16, fontWeight: '600', padding: 12},
  button: {marginHorizontal: 12, marginBottom: 8, padding: 12, borderWidth: 1, borderColor: '#0a58ca', borderRadius: 6},
  buttonText: {color: '#0a58ca', fontSize: 16},
});
