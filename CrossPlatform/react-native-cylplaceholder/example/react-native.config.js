// [EN] The Android half is built by ':cyl-rn' (android/settings.gradle), so autolinking skips it on Android.
// [CN] Android 部分由 ':cyl-rn' 编译（android/settings.gradle），所以 Android 上跳过自动链接。
module.exports = {
  dependencies: {
    'react-native-cylplaceholder': {platforms: {android: null}},
  },
};
