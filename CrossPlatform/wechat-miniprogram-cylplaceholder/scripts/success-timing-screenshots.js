#!/usr/bin/env node
/**
 * Screenshots of the example's plus page (pages/publish/publish) at exact seconds after Success started.
 *
 * The page sets `successStartedAt` (Date.now() once Success is rendered). This script connects to WeChat DevTools
 * through miniprogram-automator, opens the page again for every screenshot (reLaunch is not awaited: it resolves
 * about 1.6 s after Success already started), polls the runtime for the timestamp, waits on the runtime's clock until
 * the target second, reads Date.now() and takes a simulator screenshot. A DevTools screenshot takes about 0.75 s;
 * the frame is captured a fixed delay after that reading (the capture delay). `--calibrate` measures it: it shoots
 * across the Uploading -> Success switch and writes each shot's reading; the first shot showing Success and the last
 * one showing Uploading bound the delay (2026-11-22, DevTools 2.02.2609250 on Windows 11, two runs: 0.106-0.169 s).
 * Results (each screenshot's captured interval after Success started) go to timing.json.
 *
 * Start DevTools with automation first (port 9420 by default):
 *   "<DevTools>/cli.bat" auto --project <this folder> --auto-port 9420
 * Then:
 *   npm run success-timing -- [--port 9420] [--out <folder>] [--seconds 0.3,0.7,1.1,1.4,2,5]
 *                              [--capture-delay 0.106,0.169] [--calibrate]
 */
const fs = require('fs')
const path = require('path')
const automator = require('miniprogram-automator')

function argument(name, fallback) {
  const index = process.argv.indexOf('--' + name)
  return index >= 0 && process.argv[index + 1] ? process.argv[index + 1] : fallback
}

const port = Number(argument('port', '9420'))
const out = path.resolve(argument('out', path.join(__dirname, '..', 'out', 'success-timing')))
const seconds = argument('seconds', '0.3,0.7,1.1,1.4,2,5').split(',').map(Number).filter((s) => s >= 0)
const [delayFrom, delayTo] = argument('capture-delay', '0.106,0.169').split(',').map(Number)
const calibrate = process.argv.includes('--calibrate')

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms))

;(async () => {
  fs.mkdirSync(out, { recursive: true })
  const miniProgram = await automator.connect({ wsEndpoint: 'ws://127.0.0.1:' + port })
  const now = () => miniProgram.evaluate(() => Date.now())
  // The publish page's successStartedAt, once it is later than `after` (0 before).
  const startedAfter = (after) => miniProgram.evaluate((after) => {
    const page = getCurrentPages().slice(-1)[0]
    return page && page.route === 'pages/publish/publish' && page.data.successStartedAt > after ? page.data.successStartedAt : 0
  }, after)
  const waitForStart = async (issued) => {
    for (let i = 0; i < 2000; i++) {
      const started = await startedAfter(issued)
      if (started) return started
      await sleep(5)
    }
    throw new Error('successStartedAt was not set within 10 s')
  }
  // One shot: open the page; at `seconds` after Success started (or, calibrating, `delay` s after the reLaunch).
  const shoot = async (name, { seconds: target, delay }) => {
    const issued = await now()
    const relaunch = miniProgram.reLaunch('/pages/publish/publish').catch(() => null)
    let started = 0
    if (target !== undefined) {
      started = await waitForStart(issued)
      const wait = started + target * 1000 - (await now())
      if (wait > 0) await sleep(wait)
    } else {
      await sleep(delay * 1000)
    }
    const reading = await now()
    const file = path.join(out, name + '.png')
    await miniProgram.screenshot({ path: file })
    if (!started) started = await waitForStart(issued)
    await relaunch
    return { file, issuedToStart: (started - issued) / 1000, reading: (reading - started) / 1000 }
  }
  try {
    const shots = []
    if (calibrate) {
      const first = await shoot('calibrate-probe', { seconds: 0 })
      for (const offset of [-0.3, -0.25, -0.2, -0.17, -0.14, -0.11, -0.08, -0.05, 0]) {
        const shot = await shoot('calibrate' + offset, { delay: first.issuedToStart + offset })
        shots.push(shot)
        console.log(`${path.basename(shot.file)}: read ${shot.reading.toFixed(3)} s after Success started`)
      }
      console.log('Look at the shots: the delay is above -reading of the last Uploading shot and at most -reading of the first Success shot.')
    } else {
      for (const target of seconds) {
        const shot = await shoot('success-' + target + 's', { seconds: target })
        shot.target = target
        shot.capturedFrom = shot.reading + delayFrom
        shot.capturedTo = shot.reading + delayTo
        shots.push(shot)
        console.log(`${path.basename(shot.file)}: captured ${shot.capturedFrom.toFixed(2)}-${shot.capturedTo.toFixed(2)} s after Success started`)
      }
    }
    fs.writeFileSync(path.join(out, 'timing.json'), JSON.stringify({ captureDelay: [delayFrom, delayTo], calibrate, shots }, null, 2))
  } finally {
    miniProgram.disconnect()
  }
})().catch((error) => {
  console.error(error)
  process.exit(1)
})
