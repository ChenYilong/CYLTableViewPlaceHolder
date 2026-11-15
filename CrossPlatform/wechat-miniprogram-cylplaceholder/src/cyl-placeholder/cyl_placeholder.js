// The JavaScript API of cyl-placeholder: require('cyl-placeholder-miniprogram') or the package's src path.
'use strict'
module.exports = {
  ...require('./cyl_scenario_catalog'),
  ...require('./cyl_placeholder_hud'),
  ...require('./cyl_configuration'),
  ...require('./cyl_status'),
  // CYLRefresh lives in ../cyl-refresh (require('../cyl-refresh/cyl_refresh')); it is not re-exported here to avoid a cycle.
  CYLPlaceholderLocalization: require('./cyl_localization'),
}
