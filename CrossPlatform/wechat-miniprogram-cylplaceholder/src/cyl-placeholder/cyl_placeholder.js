// The JavaScript API of cyl-placeholder: require('cyl-placeholder-miniprogram') (src/index.js, package.json "main") or
// this file's path in a copy of src/.
//
// Each require is a plain statement naming a file: WeChat DevTools keeps only the files its static analysis reaches
// ("filter unused files"), and it does not see a require inside an object spread.
'use strict'
Object.assign(module.exports, require('./cyl_scenario_catalog'))
Object.assign(module.exports, require('../cyl-placeholder-hud/cyl_placeholder_hud'))
Object.assign(module.exports, require('./cyl_configuration'))
Object.assign(module.exports, require('./cyl_status'))
// CYLRefresh lives in ../cyl-refresh (require('../cyl-refresh/cyl_refresh')); it is not re-exported here to avoid a cycle.
module.exports.CYLPlaceholderLocalization = require('./cyl_localization')
