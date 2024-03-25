const { defineConfig } = require('@vue/cli-service')
module.exports = defineConfig({
  transpileDependencies: true,
  
  // devServer: {
  //   proxy: {
  //     '/idr': {
  //       target: 'http://192.168.20.204:9005',
  //       changeOrigin: true,
  //       pathRewrite: { '^/idr': '' },
  //     },
  //     '/idrpassport': {
  //       target: 'http://192.168.20.204:9005',
  //       changeOrigin: true,
  //       pathRewrite: { '^/idrpassport': '' },
  //     },
  //   },
  // },

  chainWebpack: (config) => {
    config.plugin('define').tap((args) => {
      const [options] = args;
      options['__VUE_PROD_HYDRATION_MISMATCH_DETAILS__'] = true;
      return args;
    });
  },
})
