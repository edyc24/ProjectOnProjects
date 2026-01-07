const {getDefaultConfig} = require('expo/metro-config');

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

module.exports = config;

