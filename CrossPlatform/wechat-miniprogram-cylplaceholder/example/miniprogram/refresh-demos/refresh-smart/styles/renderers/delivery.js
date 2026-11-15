// CYLRefreshDeliveryHeader (SmartRefreshControl's UIRefreshDeliveryHeader, MIT): a box dropping on an umbrella
// through moving clouds. Paths, colors, sizes and per-frame steps are those of the iOS port.
const { VectorImage } = require('../vector')

const P = {
  "PATH_UMBRELLA_1": "M113.91,328.86 L119.02,331.02 134.86,359.02 133.99,359.02ZM2.18,144.52c-3.67,-76.84 49.96,-122.23 96.3,-134.98 6.03,0.21 7.57,0.59 13.23,3.9 0.19,1.7 0.25,2.17 -0.41,3.98 -47.88,37.64 -55.13,79.65 -68.07,137.22C37.56,194.8 16.18,191.4 2.18,144.52Z",
  "PATH_UMBRELLA_2": "m133.99,359.02 l-0.71,-26.66 2.6,0.26 -1.02,26.4zM119.02,331.02c-3.39,-0.99 -8.53,-3.03 -8.72,-6.61 0,-0.81 -2.02,-3.63 -4.49,-6.27C88.05,299.71 7.29,218.46 2.18,144.52c17.67,43.57 33.35,45.33 41.05,10.12 0.13,-70.78 33.78,-125.48 68.07,-137.22 2.34,3.33 4.11,4.81 8.14,7.8 -22.02,65.69 -23.25,84.11 -24.14,150.23 -8.68,29.57 -37.44,32.81 -52.07,-20.81 14.12,64.06 31.66,101.57 60.64,147.13 6.2,8.38 14.74,18.4 15.15,29.25zM98.48,9.54c4.59,-1.5 17.8,-4.6 33.87,-5.07 0.95,0.95 1.38,1.91 1.14,2.91 -8.81,1.34 -16.36,3.1 -21.78,6.06 -2.53,-1.27 -7.82,-3.26 -13.23,-3.9z",
  "PATH_UMBRELLA_3": "m119.02,331.02c-1.29,-7.57 -4.22,-12.31 -6.54,-15.79 -36.86,-54.89 -63.48,-98.79 -69.25,-160.59 19.89,45.9 41.27,48.65 52.07,20.81 -1.95,-52.55 -8.04,-91.2 24.14,-150.23 10.47,-0.28 16.85,0.17 30.66,-0.34 40.19,60.54 24.92,135.95 22.16,149.57 -13.9,53.18 -66.91,34.12 -76.96,1 11.54,50.55 20.28,89.27 30,135.97 4.12,10.03 5.37,10.37 5.06,21.35 -2.82,-0.22 -8.22,-1.01 -11.35,-1.75z",
  "PATH_UMBRELLA_4": "m172.27,174.45c4.91,-51.6 -1.8,-105.99 -22.16,-149.57 2.51,-3.42 3.25,-4.36 6.59,-6.04 47.91,22.5 77.5,62.66 68.9,139.94 -16.53,49.7 -45.39,52.78 -53.33,15.68zM154.36,13.39c-6.65,-2.73 -11.65,-4.27 -20.87,-6.01 -0.25,-1.02 -0.71,-2.21 -1.14,-2.91 16.31,-0.22 27.58,2.29 37.27,4.82 -5.49,0.42 -11.39,1.87 -15.26,4.11z",
  "PATH_UMBRELLA_5": "m133.99,359.02 l14.98,-28.13 2.24,-0.75 -16.34,28.88zM141.15,332.65c0.01,-11.71 2.3,-14.29 4.13,-21.52 11.82,-46.68 16.09,-77.45 26.98,-136.68 12.18,38.55 37.7,23.31 53.33,-15.68 -4.01,53.72 -43.68,121.28 -68.8,155.25 -6.17,9.5 -8.27,16.22 -5.59,16.12 -3.69,1.47 -6.24,2.05 -10.05,2.51z",
  "PATH_UMBRELLA_6": "m225.59,158.77c1.61,-52.44 -22.26,-117.1 -68.9,-139.94 -1.48,-2.24 -1.63,-2.16 -2.34,-5.44 3.7,-3.42 9.42,-4.82 15.26,-4.11 48.59,9.81 103.07,66.75 96.62,132.26 -9.7,45.68 -35.45,51.78 -40.64,17.24z",
  "PATH_UMBRELLA_7": "m156.48,313.99c32.9,-59.38 53.82,-87.19 69.12,-155.22 12.23,38.4 28.73,22.32 40.64,-17.24 -2.11,50.59 -43.12,112.84 -99.62,171.38 -4.57,4.73 -8.31,9.42 -8.31,10.4 -0,2.28 -3.52,5.43 -7.1,6.82 -4.65,0.73 2.08,-12.86 5.27,-16.15z",
  "PATH_UMBRELLA_8": "M130.37,332.77C129.51,321.51 128.56,320.77 125.3,311.42 113.97,281.37 101.34,222.24 95.3,175.45c16.48,38.98 60.02,33.39 76.96,-1 -5.91,58.92 -10.85,88.45 -27.42,138.74 -1.67,6.75 -2.67,11.63 -3.7,19.46 -2.94,0.45 -6.48,0.45 -10.78,0.12zM119.44,25.22c-3.52,-1.25 -6.98,-3.72 -8.14,-7.8 -0.44,-1.53 -0.24,-2.79 0.41,-3.98 2.48,-4.55 14.53,-6.26 21.78,-6.06 5.29,0.15 14.87,0.72 20.87,6.01 1.82,1.61 2.74,3.95 2.34,5.44 -0.76,2.83 -4.21,5.19 -6.59,6.04 -7.49,2.68 -22.62,3.2 -30.66,0.34z",
  "PATH_BOX_1": "M0,17.5 L3.1,29.8 2.9,76.4 47.5,93 92.8,76.2V29.9L94.9,18.1 47.4,0.5Z",
  "PATH_BOX_2": "M3.1,29.8 L47.8,46.4 47.5,93 2.9,76.4ZM0,17.5 L47.9,35.4 47.8,46.4 0.2,28.8Z",
  "PATH_BOX_3": "m56.5,17.8c0,2.1 -3.8,3.8 -8.5,3.8 -4.7,0 -8.5,-1.7 -8.5,-3.8 0,-2.1 3.8,-3.8 8.5,-3.8 4.7,0 8.5,1.7 8.5,3.8zM3.1,29.8 L3.1,34.7l44.7,16.9 0,-5.1z",
  "PATH_BOX_4": "M47.9,35.4 L47.5,93 92.8,76.2V29.9l2.2,-0.8 0,-10.9z",
  "PATH_BOX_5": "M82.6,80 L92.8,62.4 92.8,76.2ZM47.6,79.8 L59.8,88.4 47.5,93ZM47.8,46.4 L92.8,29.9 92.8,34.2 47.8,51.6Z",
  "PATH_CLOUD": [
    "M63,0.1A22.6,22.4 0,0 0,42.1 14.2,17.3 17.3,0 0,0 30.9,10.2 17.3,17.3 0,0 0,13.7 25.8,8.8 8.8,0 0,0 8.7,24.2 8.8,8.8 0,0 0,0 32h99a7.9,7.9 0,0 0,0 -0.6,7.9 7.9,0 0,0 -7.9,-7.9 7.9,7.9 0,0 0,-5.8 2.6,22.6 22.4,0 0,0 0.3,-3.6A22.6,22.4 0,0 0,63 0.1Z"
  ]
}

function create() {
  const umbrella = new VectorImage(
    [P.PATH_UMBRELLA_1, P.PATH_UMBRELLA_2, P.PATH_UMBRELLA_3, P.PATH_UMBRELLA_4, P.PATH_UMBRELLA_5, P.PATH_UMBRELLA_6, P.PATH_UMBRELLA_7, P.PATH_UMBRELLA_8],
    ['#92dfeb', '#6dd0e9', '#4fc3e7', '#2fb6e6', '#25a9de', '#11abe4', '#0e9bd8', '#40b7e1'])
  umbrella.setGeometricWidth(200)
  const box = new VectorImage([P.PATH_BOX_1, P.PATH_BOX_2, P.PATH_BOX_3, P.PATH_BOX_4, P.PATH_BOX_5],
    ['#f8b147', '#f2973c', '#ed8030', '#fec051', '#f7ad49'])
  box.setGeometricWidth(50)
  const cloud = new VectorImage(P.PATH_CLOUD, ['#ffffff'])
  cloud.setGeometricHeight(20)
  const cw = cloud.size.w
  return { umbrella, box, cloud, cloud1x: -cw, cloud2x: -cw, cloud3x: -cw, appreciation: 0 }
}

function status(m, old, now) {
  if (now === 'Refreshing') {
    m.box.opacity = 1
  } else if (now === 'Idle') {
    m.appreciation = 0
    m.cloud1x = m.cloud2x = m.cloud3x = -m.cloud.size.w
  }
}

/** calculateFrame: one step per 60 Hz frame on iOS, scaled by the frame time here. */
function step(m, width, dt) {
  const k = dt * 60
  const cw = m.cloud.size.w
  m.cloud1x += 7 * k
  m.cloud2x += 4 * k
  m.cloud3x += 9 * k
  if (m.cloud1x > width + cw) m.cloud1x = -cw
  if (m.cloud2x > width + cw) m.cloud2x = -cw
  if (m.cloud3x > width + cw) m.cloud3x = -cw
  m.appreciation += 0.08 * k
}

function draw(ctx, v, m) {
  const width = v.w
  const height = v.h
  const expand = v.expand
  const active = v.status === 'Refreshing'
  if (active) step(m, width, v.dt)
  else m.box.opacity = Math.max(0.1, 1 - Math.max(0, v.percent - 1))
  const shake = (expand / 13) * Math.cos(m.appreciation)
  ctx.fillStyle = v.primary
  ctx.fillRect(0, 0, width, height)
  if (active) {
    // drawCloud, then the swing that drawCloud leaves on the context for the box and the umbrella.
    m.cloud.moveTo(m.cloud1x, expand / 3); m.cloud.render(ctx)
    m.cloud.moveTo(m.cloud2x, expand / 2); m.cloud.render(ctx)
    m.cloud.moveTo(m.cloud3x, (expand * 2) / 3); m.cloud.render(ctx)
    ctx.translate(width / 2, expand / 2 - expand)
    ctx.rotate((Math.sin(m.appreciation) * Math.PI * 5) / 180)
    ctx.translate(-width / 2, expand - expand / 2)
  }
  // drawBox
  const bw = m.box.size.w
  const bh = m.box.size.h
  const centerY = height - expand / 2 + shake
  const centerYBox = centerY + (expand / 2 - bh) - Math.min(expand / 2 - bh, m.appreciation * 100)
  m.box.moveTo(width / 2 - bw / 2, centerYBox - bh / 4)
  m.box.render(ctx)
  // drawUmbrella
  if (active) {
    const uh = m.umbrella.size.h
    const uw = m.umbrella.size.w
    const cyU = centerY - expand + Math.min(expand, m.appreciation * 100)
    m.umbrella.moveTo(width / 2 - uw / 2, cyU - uh)
    m.umbrella.render(ctx)
  }
}

module.exports = { height: 150, triggerRate: 0.7, primary: '#f5f5f5', accent: '#6ea9ff', stretch: true, create, status, draw }
