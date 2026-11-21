const { applyStoredLanguage } = require('./utils/l10n')

App({
  onLaunch() {
    // The language chosen with the 🌐 button (stored), else the system's.
    applyStoredLanguage()
  },
})
