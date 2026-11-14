// The default `animation` generic of cyl-placeholder: no player. A page plugs a real one in with
// generic:animation="cyl-lottie" (cyl-lottie-miniprogram); it gets path, loop, speed and autoplay.
Component({
  properties: { path: String, loop: Boolean, speed: Number, autoplay: Boolean, label: String },
  methods: {
    cyl_playFromStart() {},
  },
})
