// { "framework": "Vue"}

/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, {
/******/ 				configurable: false,
/******/ 				enumerable: true,
/******/ 				get: getter
/******/ 			});
/******/ 		}
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 8);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports, __webpack_require__) {

var __vue_exports__, __vue_options__
var __vue_styles__ = []

/* styles */
__vue_styles__.push(__webpack_require__(1)
)

/* script */
__vue_exports__ = __webpack_require__(2)

/* template */
var __vue_template__ = __webpack_require__(3)
__vue_options__ = __vue_exports__ = __vue_exports__ || {}
if (
  typeof __vue_exports__.default === "object" ||
  typeof __vue_exports__.default === "function"
) {
if (Object.keys(__vue_exports__).some(function (key) { return key !== "default" && key !== "__esModule" })) {console.error("named exports are not supported in *.vue files.")}
__vue_options__ = __vue_exports__ = __vue_exports__.default
}
if (typeof __vue_options__ === "function") {
  __vue_options__ = __vue_options__.options
}
__vue_options__.__file = "/Users/momo/Documents/MainProject/Meilishuo/src/components/WaterFall.vue"
__vue_options__.render = __vue_template__.render
__vue_options__.staticRenderFns = __vue_template__.staticRenderFns
__vue_options__._scopeId = "data-v-a48a879c"
__vue_options__.style = __vue_options__.style || {}
__vue_styles__.forEach(function (module) {
  for (var name in module) {
    __vue_options__.style[name] = module[name]
  }
})
if (typeof __register_static_styles__ === "function") {
  __register_static_styles__(__vue_options__._scopeId, __vue_styles__)
}

module.exports = __vue_exports__


/***/ }),
/* 1 */
/***/ (function(module, exports) {

module.exports = {
  "loading": {
    "left": 0,
    "right": 0,
    "height": "40",
    "display": "flex",
    "MsFlexAlign": "center",
    "WebkitAlignItems": "center",
    "WebkitBoxAlign": "center",
    "alignItems": "center",
    "justifyContent": "center",
    "backgroundColor": "#717171"
  },
  "waterfall-container": {
    "left": 0,
    "right": 0,
    "bottom": 0,
    "top": 0,
    "position": "absolute"
  },
  "waterfall-wrapper": {
    "left": 0,
    "right": 0,
    "bottom": 0,
    "top": "100",
    "position": "absolute"
  },
  "waterfall-item-wrapper": {
    "paddingTop": "10",
    "paddingRight": "10",
    "paddingBottom": "10",
    "paddingLeft": "10"
  },
  "waterfall-desc-text": {
    "fontSize": "25"
  },
  "waterfall-image": {
    "left": 0,
    "right": 0,
    "top": 0,
    "height": "300"
  },
  "waterfall-cell-horizontal": {
    "left": 0,
    "top": 0,
    "right": 0,
    "height": "80",
    "alignItems": "center",
    "flexDirection": "row",
    "justifyContent": "space-between"
  },
  "waterfall-avatar-image": {
    "width": "50",
    "height": "50",
    "borderRadius": "25",
  },
  "waterfall-avatar-title": {
    "alignItems": "center",
    "flexDirection": "row"
  },
  "waterfall-name": {
    "left": "20",
    "fontSize": "22"
  },
  "waterfall-like-container": {
    "flexDirection": "row",
    "alignItems": "center"
  },
  "waterfall-like-icon": {
    "width": "50",
    "height": "50"
  },
  "waterfall-like-count": {
    "fontSize": "22"
  }
}

/***/ }),
/* 2 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//

exports.default = {
  data: function data() {
    return {
      loadinging: false,
      lists: [],
      moreData: [],
      love: ''
    };
  },

  methods: {
    onloading: function onloading(event) {
      var _this = this;

      this.loadinging = true;
      setTimeout(function () {
        _this.loadinging = false;
        _this.lists = _this.lists.concat(_this.moreData);
      }, 200);
    }
  },
  created: function created() {
    var waterDataList = new BroadcastChannel('DataList');
    var that = this;
    waterDataList.onmessage = function (event) {
      that.lists = event.data;
      that.moreData = event.data;
      that.love = 'https://s.momocdn.com/w/u/others/2019/10/22/1571734558042-mls_love.png';
    };
  }
};

/***/ }),
/* 3 */
/***/ (function(module, exports) {

module.exports={render:function (){var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: ["waterfall-container"]
  }, [_c('waterfall', {
    staticClass: ["waterfall-wrapper"],
    attrs: {
      "columnCount": "2",
      "columnWidth": "auto"
    }
  }, [_vm._l((_vm.lists), function(item) {
    return _c('cell', {
      appendAsTree: true,
      attrs: {
        "append": "tree"
      }
    }, [_c('div', {
      staticClass: ["waterfall-item-wrapper"]
    }, [_c('image', {
      staticClass: ["waterfall-image"],
      attrs: {
        "src": item.pic_big
      }
    }), _c('text', {
      staticClass: ["waterfall-desc-text"]
    }, [_vm._v(_vm._s(item.title))]), _c('div', {
      staticClass: ["waterfall-cell-horizontal"]
    }, [_c('div', {
      staticClass: ["waterfall-avatar-title"]
    }, [_c('image', {
      staticClass: ["waterfall-avatar-image"],
      attrs: {
        "src": item.pic_small
      }
    }), _c('text', {
      staticClass: ["waterfall-name"]
    }, [_vm._v(_vm._s(item.artist_name))])]), _c('div', {
      staticClass: ["waterfall-like-container"]
    }, [_c('image', {
      staticClass: ["waterfall-like-icon"],
      attrs: {
        "src": _vm.love
      }
    }), _c('text', {
      staticClass: ["waterfall-like-count"]
    }, [_vm._v(_vm._s(item.file_duration))])])])])])
  }), _c('loading', {
    staticClass: ["loading"],
    attrs: {
      "display": _vm.loadinging ? 'show' : 'hide'
    },
    on: {
      "loading": _vm.onloading
    }
  }, [_c('loading-indicator')])], 2)], 1)
},staticRenderFns: []}
module.exports.render._withStripped = true

/***/ }),
/* 4 */,
/* 5 */,
/* 6 */,
/* 7 */,
/* 8 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var _index = __webpack_require__(9);

var _index2 = _interopRequireDefault(_index);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

_index2.default.el = '#root';
new Vue(_index2.default);

/***/ }),
/* 9 */
/***/ (function(module, exports, __webpack_require__) {

var __vue_exports__, __vue_options__
var __vue_styles__ = []

/* styles */
__vue_styles__.push(__webpack_require__(10)
)

/* script */
__vue_exports__ = __webpack_require__(11)

/* template */
var __vue_template__ = __webpack_require__(12)
__vue_options__ = __vue_exports__ = __vue_exports__ || {}
if (
  typeof __vue_exports__.default === "object" ||
  typeof __vue_exports__.default === "function"
) {
if (Object.keys(__vue_exports__).some(function (key) { return key !== "default" && key !== "__esModule" })) {console.error("named exports are not supported in *.vue files.")}
__vue_options__ = __vue_exports__ = __vue_exports__.default
}
if (typeof __vue_options__ === "function") {
  __vue_options__ = __vue_options__.options
}
__vue_options__.__file = "/Users/momo/Documents/MainProject/Meilishuo/src/index.vue"
__vue_options__.render = __vue_template__.render
__vue_options__.staticRenderFns = __vue_template__.staticRenderFns
__vue_options__._scopeId = "data-v-2964abc9"
__vue_options__.style = __vue_options__.style || {}
__vue_styles__.forEach(function (module) {
  for (var name in module) {
    __vue_options__.style[name] = module[name]
  }
})
if (typeof __register_static_styles__ === "function") {
  __register_static_styles__(__vue_options__._scopeId, __vue_styles__)
}

module.exports = __vue_exports__


/***/ }),
/* 10 */
/***/ (function(module, exports) {

module.exports = {
  "head-header-line-wrapper": {
    "position": "absolute",
    "top": "20",
    "left": "20",
    "right": "20",
    "height": "150"
  },
  "head-header-line": {
    "position": "relative",
    "flexDirection": "row"
  },
  "head-tips-horizontal": {
    "flexDirection": "row"
  },
  "head-vertical-between": {
    "position": "relative",
    "justifyContent": "space-between",
    "marginLeft": "20"
  },
  "head-attention": {
    "position": "absolute",
    "top": 0,
    "right": 0,
    "width": "100",
    "height": "50",
    "alignItems": "center",
    "justifyContent": "center",
    "borderWidth": "1",
    "borderColor": "#FFFFFF",
    "borderRadius": "5"
  },
  "head-horizontal-between": {
    "justifyContent": "space-between",
    "flexDirection": "row",
    "right": 0
  },
  "wrapper": {
    "top": 0,
    "left": 0,
    "right": 0,
    "bottom": 0
  },
  "text-title": {
    "color": "#FFFFFF",
    "fontSize": "35"
  },
  "text-tip": {
    "color": "#FFFFFF",
    "fontSize": "20"
  },
  "related-title-text": {
    "color": "#FFFFFF",
    "fontSize": "25",
    "left": "10"
  },
  "text-horizontal-list": {
    "maxWidth": "200",
    "color": "#FFFFFF"
  },
  "head-wrapper": {
    "left": 0,
    "right": 0,
    "top": 0,
    "height": "250",
    "backgroundColor": "#dddddd"
  },
  "related-container": {
    "position": "absolute",
    "flexDirection": "row",
    "left": 0,
    "bottom": 0,
    "right": 0,
    "height": "60",
    "alignItems": "center"
  },
  "elevator": {
    "top": 0,
    "left": "150",
    "right": 0,
    "height": "60",
    "position": "absolute",
    "flexDirection": "row"
  },
  "elevator-container": {
    "justifyContent": "center"
  },
  "elevator-item": {
    "marginLeft": "20",
    "marginRight": "20",
    "paddingLeft": "20",
    "paddingRight": "20",
    "height": "50",
    "borderRadius": "25",
    "justifyContent": "center",
    "backgroundColor": "rgba(0,0,0,0.4)"
  },
  "elevator-item-text": {
    "color": "#FFFFFF",
    "fontSize": "26"
  },
  "bottom-container": {
    "top": "250",
    "left": 0,
    "right": 0,
    "bottom": 0,
    "position": "absolute",
    "borderTopLeftRadius": "10",
    "borderTopRightRadius": "10",
    "backgroundColor": "#FFFFFF"
  },
  "waterfall-swap": {
    "top": 0,
    "left": "20",
    "right": 0,
    "height": "100",
    "alignItems": "center",
    "flexDirection": "row"
  },
  "waterfall-swap-title": {
    "paddingLeft": "20"
  }
}

/***/ }),
/* 11 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});

var _WaterFall = __webpack_require__(0);

var _WaterFall2 = _interopRequireDefault(_WaterFall);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var homeDataList = new BroadcastChannel('DataList'); //
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//

exports.default = {
  name: 'App',

  components: {
    WaterFall: _WaterFall2.default
  },
  data: function data() {
    return {
      relatedDataList: [],
      logo: '',
      icon_star: '',
      icon_scan: '',
      icon_header: ''
    };
  },

  // ready: function () {
  //   var modal = weex.requireModule('modal')
  //   modal.toast({
  //     message: 'hahahahahah1',
  //     duration: 3
  //   })
  // },

  created: function created() {
    var that = this;
    setTimeout(function () {
      weex.requireModule('dataModel').asyncReadMapFile(function (response, keepalive) {
        that.relatedDataList = response.relatedDataList;
        that.logo = 'http://qukufile2.qianqian.com/data2/pic/bb1f40de3867cbc68af12b8ab03dc350/670342330/670342330.jpg@s_2,w_150,h_150';
        that.icon_star = 'https://s.momocdn.com/w/u/others/2019/10/18/1571393657050-mls_star.png';
        that.icon_scan = 'https://s.momocdn.com/w/u/others/2019/10/18/1571393656549-mls_scan.png';
        that.icon_header = 'https://s.momocdn.com/w/u/others/2019/10/18/1571393657050-mls_header.png';
        homeDataList.postMessage(response.result);
      });
    }, 200);
  }
  // mounted () {
  //   this.$nextTick(function () {
  //     // Code that will run only after the
  //     // entire view has been rendered
  //     // setTimeout(function () {
  //     //   this.relatedDataList = ['呵呵', '哈哈', '嘿嘿']
  //     // }, 3000)
  //     // console.log('哈哈哈哈哈哈哈哈')
  //   })
  // }
};

/***/ }),
/* 12 */
/***/ (function(module, exports) {

module.exports={render:function (){var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: ["wrapper"]
  }, [_c('div', {
    staticClass: ["head-wrapper"]
  }, [_c('div', {
    staticClass: ["head-header-line-wrapper"]
  }, [_c('div', {
    staticClass: ["head-header-line"]
  }, [_c('div', {
    staticClass: ["head-header-icon"]
  }, [_c('image', {
    staticStyle: {
      width: "150px",
      height: "150px"
    },
    attrs: {
      "src": _vm.logo
    }
  })]), _c('div', {
    staticClass: ["head-vertical-between"]
  }, [_c('div', [_c('text', {
    staticClass: ["text-title"]
  }, [_vm._v("一周穿搭不重样")]), _c('div', {
    staticClass: ["head-tips-horizontal"]
  }, [_c('image', {
    staticStyle: {
      width: "30px",
      height: "30px"
    },
    attrs: {
      "src": _vm.icon_star
    }
  }), _vm._m(0), _c('image', {
    staticStyle: {
      width: "30px",
      height: "30px"
    },
    attrs: {
      "src": _vm.icon_scan
    }
  }), _vm._m(1)])]), _c('div', {
    staticClass: ["head-tips-horizontal"]
  }, [_c('image', {
    staticStyle: {
      width: "40px",
      height: "50px"
    },
    attrs: {
      "src": _vm.icon_header
    }
  }), _c('text', {
    staticClass: ["text-tip"]
  }, [_vm._v("小美酱Pick榜 创建")])])])]), _vm._m(2)]), _c('div', {
    staticClass: ["related-container"]
  }, [_c('text', {
    staticClass: ["related-title-text"]
  }, [_vm._v("相关灵感集:")]), _c('scroller', {
    staticClass: ["elevator"],
    attrs: {
      "scrollDirection": "horizontal",
      "showScrollbar": "true"
    }
  }, _vm._l((_vm.relatedDataList), function(name) {
    return _c('div', {
      staticClass: ["elevator-container"]
    }, [_c('div', {
      staticClass: ["elevator-item"]
    }, [_c('text', {
      staticClass: ["elevator-item-text"]
    }, [_vm._v(_vm._s(name))])])])
  }))])]), _c('div', {
    staticClass: ["bottom-container"]
  }, [_vm._m(3), _c('WaterFall', {
    attrs: {
      "id": "MWaterFall"
    }
  })], 1)])
},staticRenderFns: [function (){var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', [_c('text', {
    staticClass: ["text-tip"]
  }, [_vm._v("200篇")])])
},function (){var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', [_c('text', {
    staticClass: ["text-tip"]
  }, [_vm._v("   6790")])])
},function (){var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: ["head-attention"]
  }, [_c('text', {
    staticClass: ["text-tip"]
  }, [_vm._v("关注")])])
},function (){var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: ["waterfall-swap"]
  }, [_c('div', {
    staticStyle: {
      alignItems: "center"
    }
  }, [_c('text', {
    staticClass: ["waterfall-swap-title"]
  }, [_vm._v("热门")]), _c('div', {
    staticStyle: {
      width: "10px",
      height: "3px"
    }
  })]), _c('div', {
    staticStyle: {
      alignItems: "center"
    }
  }, [_c('text', {
    staticClass: ["waterfall-swap-title"]
  }, [_vm._v("关注")]), _c('div', {
    staticStyle: {
      width: "10px",
      height: "3px"
    }
  })])])
}]}
module.exports.render._withStripped = true

/***/ })
/******/ ]);