const path = require('path');
const {getDefaultConfig, mergeConfig} = require('@react-native/metro-config');

// [EN] react-native-cylplaceholder is the folder above this app (`file:..`): watch it, and take react / react-native
//      only from this app's node_modules so there is one copy of each.
// [CN] react-native-cylplaceholder 就是本应用上一级目录（`file:..`）：监视它，并且 react / react-native 只取本应用的，保证各只有一份。
const library = path.resolve(__dirname, '..');

/** @type {import('metro-config').MetroConfig} */
const config = {
  watchFolders: [library],
  resolver: {
    nodeModulesPaths: [path.resolve(__dirname, 'node_modules')],
    blockList: [new RegExp(`${library.replace(/[\\/]/g, '[\\\\/]')}[\\\\/]node_modules[\\\\/].*`)],
  },
};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);
