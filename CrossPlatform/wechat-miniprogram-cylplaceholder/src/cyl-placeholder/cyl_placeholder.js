// The JavaScript API of cyl-placeholder: require('cyl-placeholder-miniprogram') or the package's src path.
'use strict'
module.exports = {
  ...require('./cyl_scenario_catalog'),
  ...require('./cyl_placeholder_hud'),
  CYLPlaceholderLocalization: require('./cyl_localization'),
}
