const {getDefaultConfig} = require('expo/metro-config');
const path = require('path');

/**
 * Metro configuration
 * https://docs.expo.dev/guides/customizing-metro
 *
 * @type {import('expo/metro-config').MetroConfig}
 */
const config = getDefaultConfig(__dirname);

// Add support for additional file extensions
config.resolver.sourceExts.push('mjs', 'cjs');

// Disable package exports to avoid import.meta issues
config.resolver.unstable_enablePackageExports = false;

// Add assets folder to watchFolders
config.watchFolders = [
  path.resolve(__dirname, './assets'),
];

// Ensure assets are included in resolver
config.resolver.assetExts.push('png', 'jpg', 'jpeg', 'PNG', 'JPG', 'JPEG', 'jpeg', 'JPEG');

module.exports = config;

