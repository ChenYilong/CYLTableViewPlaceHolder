// A read-only, monospaced view of a raw text file of the package (the "File" page of CYLConfigurationViewController).
// Query: ?file=NAME (a file of /configurations), or ?path=PACKAGE_PATH; ?title= overrides the title (default: the
// file name).
Page({
  data: { text: '' },

  onLoad(query) {
    const file = query.file ? decodeURIComponent(query.file) : ''
    // A mini program package keeps only known file types: property lists and other text files ship as <name>.json
    // holding the text as one JSON string.
    const packaged = /\.plist$/.test(file) ? file + '.json' : file
    const path = query.path ? decodeURIComponent(query.path) : file ? 'configurations/' + packaged : ''
    const title = query.title ? decodeURIComponent(query.title) : path.replace(/^.*\//, '')
    wx.setNavigationBarTitle({ title })
    let text = ''
    try {
      text = wx.getFileSystemManager().readFileSync(path.replace(/^\//, ''), 'utf8')
      // A wrapped text file (see above) is a JSON string: show the text it holds.
      if (/\.json$/.test(path) && /^\s*"/.test(text)) text = JSON.parse(text)
    } catch (e) {
      // Like the iOS page, an unreadable file shows an empty text view.
    }
    this.setData({ text })
  },
})
