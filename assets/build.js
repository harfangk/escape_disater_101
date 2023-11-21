const esbuild = require("esbuild");

const args = process.argv.slice(2);
const watch = args.includes('--watch');
const deploy = args.includes('--deploy');

const loader = {
  // Add loaders for images/fonts/etc, e.g. { '.svg': 'file' }
};

const plugins = [
  // Add and configure plugins here
];

// Define esbuild options
let opts = {
  entryPoints: ["js/app.js"],
  bundle: true,
  logLevel: "info",
  target: "es2017",
  outdir: "../priv/static/assets",
  external: ["*.css", "fonts/*", "images/*"],
  loader: loader,
  plugins: plugins,
  define: {
    "VWORLD_APP_URL": "'http://localhost:4000'",
    "VWORLD_API_KEY": "'B1E465C1-3237-368E-8ACF-AA0E89EA8C43'",
  }
};

if (deploy) {
  opts = {
    ...opts,
    minify: true,
    define: {
      "VWORLD_APP_URL": "'https://escape-disaster-shy-frost-4934.fly.dev'",
      "VWORLD_API_KEY": "'0BFADD53-593C-36B6-B798-790E5AF71A26'",
    }
  };
}

if (watch) {
  opts = {
    ...opts,
    sourcemap: "inline",
  };
  esbuild
    .context(opts)
    .then((ctx) => {
      ctx.watch();
    })
    .catch((_error) => {
      process.exit(1);
    });
} else {
  esbuild.build(opts);
}
