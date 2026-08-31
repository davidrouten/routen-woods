// chartist@1.5.0 downloaded from https://ga.jspm.io/npm:chartist@1.5.0/dist/index.js

const e={svg:"http://www.w3.org/2000/svg",xmlns:"http://www.w3.org/2000/xmlns/",xhtml:"http://www.w3.org/1999/xhtml",xlink:"http://www.w3.org/1999/xlink",ct:"http://gionkunz.github.com/chartist-js/ct"};const t=8;const s={"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#039;"};function i(e,t){return typeof e==="number"?e+t:e}function n(e){if(typeof e==="string"){const t=/^(\d+)\s*(.*)$/g.exec(e);return{value:t?+t[1]:0,unit:(t===null||t===void 0?void 0:t[2])||void 0}}return{value:Number(e)}}
/**
 * Generates a-z from a number 0 to 26
 * @param n A number from 0 to 26 that will result in a letter a-z
 * @return A character from a-z based on the input number n
 */function r(e){return String.fromCharCode(97+e%26)}const a=2221e-19;
/**
 * Calculate the order of magnitude for the chart scale
 * @param value The value Range of the chart
 * @return The order of magnitude
 */function o(e){return Math.floor(Math.log(Math.abs(e))/Math.LN10)}
/**
 * Project a data length into screen coordinates (pixels)
 * @param axisLength The svg element for the chart
 * @param length Single data value from a series array
 * @param bounds All the values to set the bounds of the chart
 * @return The projected data length in pixels
 */function l(e,t,s){return t/s.range*e}
/**
 * This helper function can be used to round values with certain precision level after decimal. This is used to prevent rounding errors near float point precision limit.
 * @param value The value that should be rounded with precision
 * @param [digits] The number of digits after decimal used to do the rounding
 * @returns Rounded value
 */function c(e,s){const i=Math.pow(10,s||t);return Math.round(e*i)/i}
/**
 * Pollard Rho Algorithm to find smallest factor of an integer value. There are more efficient algorithms for factorization, but this one is quite efficient and not so complex.
 * @param num An integer number where the smallest factor should be searched for
 * @returns The smallest integer factor of the parameter num.
 */function h(e){if(e===1)return e;function t(e,s){return e%s===0?s:t(s,e%s)}function s(e){return e*e+1}let i=2;let n=2;let r;if(e%2===0)return 2;do{i=s(i)%e;n=s(s(n))%e;r=t(Math.abs(i-n),e)}while(r===1);return r}
/**
 * Calculate cartesian coordinates of polar coordinates
 * @param centerX X-axis coordinates of center point of circle segment
 * @param centerY X-axis coordinates of center point of circle segment
 * @param radius Radius of circle segment
 * @param angleInDegrees Angle of circle segment in degrees
 * @return Coordinates of point on circumference
 */function u(e,t,s,i){const n=(i-90)*Math.PI/180;return{x:e+s*Math.cos(n),y:t+s*Math.sin(n)}}
/**
 * Calculate and retrieve all the bounds for the chart and return them in one array
 * @param axisLength The length of the Axis used for
 * @param highLow An object containing a high and low property indicating the value range of the chart.
 * @param scaleMinSpace The minimum projected length a step should result in
 * @param onlyInteger
 * @return All the values to set the bounds of the chart
 */function d(e,t,s){let i=arguments.length>3&&arguments[3]!==void 0&&arguments[3];const n={high:t.high,low:t.low,valueRange:0,oom:0,step:0,min:0,max:0,range:0,numberOfSteps:0,values:[]};n.valueRange=n.high-n.low;n.oom=o(n.valueRange);n.step=Math.pow(10,n.oom);n.min=Math.floor(n.low/n.step)*n.step;n.max=Math.ceil(n.high/n.step)*n.step;n.range=n.max-n.min;n.numberOfSteps=Math.round(n.range/n.step);const r=l(e,n.step,n);const u=r<s;const d=i?h(n.range):0;if(i&&l(e,1,n)>=s)n.step=1;else if(i&&d<n.step&&l(e,d,n)>=s)n.step=d;else{let t=0;for(;;){if(u&&l(e,n.step,n)<=s)n.step*=2;else{if(u||!(l(e,n.step/2,n)>=s))break;n.step/=2;if(i&&n.step%1!==0){n.step*=2;break}}if(t++>1e3)throw new Error("Exceeded maximum number of iterations while optimizing scale step!")}}n.step=Math.max(n.step,a);function m(e,t){e===(e+=t)&&(e*=1+(t>0?a:-a));return e}let f=n.min;let p=n.max;while(f+n.step<=n.low)f=m(f,n.step);while(p-n.step>=n.high)p=m(p,-n.step);n.min=f;n.max=p;n.range=n.max-n.min;const g=[];for(let e=n.min;e<=n.max;e=m(e,n.step)){const t=c(e);t!==g[g.length-1]&&g.push(t)}n.values=g;return n}function m(){let e=arguments.length>0&&arguments[0]!==void 0?arguments[0]:{};for(var t=arguments.length,s=new Array(t>1?t-1:0),i=1;i<t;i++)s[i-1]=arguments[i];for(let t=0;t<s.length;t++){const i=s[t];const n=Object.getPrototypeOf(e);for(const t in i){if(n!==null&&t in n)continue;const s=i[t];e[t]=typeof s!=="object"||s===null||s instanceof Array?s:m(e[t],s)}}return e}
/**
 * Helps to simplify functional style code
 * @param n This exact value will be returned by the noop function
 * @return The same value that was provided to the n parameter
 */const f=e=>e;function p(e,t){return Array.from({length:e},t?(e,s)=>t(s):()=>{})}const g=(e,t)=>e+(t||0);const v=(e,t)=>p(Math.max(...e.map((e=>e.length))),(s=>t(...e.map((e=>e[s])))));function x(e,t){return e!==null&&typeof e==="object"&&Reflect.has(e,t)}function y(e){return e!==null&&isFinite(e)}function w(e){return!e&&e!==0}function b(e){return y(e)?Number(e):void 0}function E(e){return!!Array.isArray(e)&&e.every(Array.isArray)}function A(e,t){let s=arguments.length>2&&arguments[2]!==void 0&&arguments[2];let i=0;e[s?"reduceRight":"reduce"](((e,s,n)=>t(s,i++,n)),void 0)}function S(e,t){const s=Array.isArray(e)?e[t]:x(e,"data")?e.data[t]:null;return x(s,"meta")?s.meta:void 0}function C(e){return e===null||e===void 0||typeof e==="number"&&isNaN(e)}function M(e){return Array.isArray(e)&&e.every((e=>Array.isArray(e)||x(e,"data")))}function N(e){return typeof e==="object"&&e!==null&&(Reflect.has(e,"x")||Reflect.has(e,"y"))}function L(e){let t=arguments.length>1&&arguments[1]!==void 0?arguments[1]:"y";return N(e)&&x(e,t)?b(e[t]):b(e)}
/**
 * Get highest and lowest value of data array. This Array contains the data that will be visualized in the chart.
 * @param data The array that contains the data to be visualized in the chart
 * @param options The Object that contains the chart options
 * @param dimension Axis dimension 'x' or 'y' used to access the correct value and high / low configuration
 * @return An object that contains the highest and lowest value that will be visualized on the chart.
 */function O(e,t,s){t={...t,...s?s==="x"?t.axisX:t.axisY:{}};const i={high:t.high===void 0?-Number.MAX_VALUE:+t.high,low:t.low===void 0?Number.MAX_VALUE:+t.low};const n=t.high===void 0;const r=t.low===void 0;function a(e){if(!C(e))if(Array.isArray(e))for(let t=0;t<e.length;t++)a(e[t]);else{const t=Number(s&&x(e,s)?e[s]:e);n&&t>i.high&&(i.high=t);r&&t<i.low&&(i.low=t)}}(n||r)&&a(e);if(t.referenceValue||t.referenceValue===0){i.high=Math.max(t.referenceValue,i.high);i.low=Math.min(t.referenceValue,i.low)}if(i.high<=i.low)if(i.low===0)i.high=1;else if(i.low<0)i.high=0;else if(i.high>0)i.low=0;else{i.high=1;i.low=0}return i}function B(e){let t=arguments.length>1&&arguments[1]!==void 0&&arguments[1],s=arguments.length>2?arguments[2]:void 0,i=arguments.length>3?arguments[3]:void 0;let n;const r={labels:(e.labels||[]).slice(),series:P(e.series,s,i)};const a=r.labels.length;if(E(r.series)){n=Math.max(a,...r.series.map((e=>e.length)));r.series.forEach((e=>{e.push(...p(Math.max(0,n-e.length)))}))}else n=r.series.length;r.labels.push(...p(Math.max(0,n-a),(()=>"")));t&&k(r);return r}function k(e){var t;(t=e.labels)===null||t===void 0?void 0:t.reverse();e.series.reverse();for(const t of e.series)x(t,"data")?t.data.reverse():Array.isArray(t)&&t.reverse()}function _(e,t){let s;let i;if(typeof e!=="object"){const n=b(e);t==="x"?s=n:i=n}else{x(e,"x")&&(s=b(e.x));x(e,"y")&&(i=b(e.y))}if(s!==void 0||i!==void 0)return{x:s,y:i}}function j(e,t){if(!C(e))return t?_(e,t):b(e)}function I(e,t){return Array.isArray(e)?e.map((e=>x(e,"value")?j(e.value,t):j(e,t))):I(e.data,t)}function P(e,t,s){if(M(e))return e.map((e=>I(e,t)));const i=I(e,t);return s?i.map((e=>[e])):i}
/**
 * Splits a list of coordinates and associated values into segments. Each returned segment contains a pathCoordinates
 * valueData property describing the segment.
 *
 * With the default options, segments consist of contiguous sets of points that do not have an undefined value. Any
 * points with undefined values are discarded.
 *
 * **Options**
 * The following options are used to determine how segments are formed
 * ```javascript
 * var options = {
 *   // If fillHoles is true, undefined values are simply discarded without creating a new segment. Assuming other options are default, this returns single segment.
 *   fillHoles: false,
 *   // If increasingX is true, the coordinates in all segments have strictly increasing x-values.
 *   increasingX: false
 * };
 * ```
 *
 * @param pathCoordinates List of point coordinates to be split in the form [x1, y1, x2, y2 ... xn, yn]
 * @param valueData List of associated point values in the form [v1, v2 .. vn]
 * @param options Options set by user
 * @return List of segments, each containing a pathCoordinates and valueData property.
 */function z(e,t,s){const i={increasingX:false,fillHoles:false,...s};const n=[];let r=true;for(let s=0;s<e.length;s+=2)if(L(t[s/2].value)===void 0)i.fillHoles||(r=true);else{i.increasingX&&s>=2&&e[s]<=e[s-2]&&(r=true);if(r){n.push({pathCoordinates:[],valueData:[]});r=false}n[n.length-1].pathCoordinates.push(e[s],e[s+1]);n[n.length-1].valueData.push(t[s/2])}return n}function X(e){let t="";if(e===null||e===void 0)return e;t=typeof e==="number"?""+e:typeof e==="object"?JSON.stringify({data:e}):String(e);return Object.keys(s).reduce(((e,t)=>e.replaceAll(t,s[t])),t)}function Y(e){if(typeof e!=="string")return e;if(e==="NaN")return NaN;e=Object.keys(s).reduce(((e,t)=>e.replaceAll(s[t],t)),e);let t=e;if(typeof e==="string")try{t=JSON.parse(e);t=t.data!==void 0?t.data:t}catch(e){}return t}class SvgList{call(e,t){this.svgElements.forEach((s=>Reflect.apply(s[e],s,t)));return this}attr(){for(var e=arguments.length,t=new Array(e),s=0;s<e;s++)t[s]=arguments[s];return this.call("attr",t)}elem(){for(var e=arguments.length,t=new Array(e),s=0;s<e;s++)t[s]=arguments[s];return this.call("elem",t)}root(){for(var e=arguments.length,t=new Array(e),s=0;s<e;s++)t[s]=arguments[s];return this.call("root",t)}getNode(){for(var e=arguments.length,t=new Array(e),s=0;s<e;s++)t[s]=arguments[s];return this.call("getNode",t)}foreignObject(){for(var e=arguments.length,t=new Array(e),s=0;s<e;s++)t[s]=arguments[s];return this.call("foreignObject",t)}text(){for(var e=arguments.length,t=new Array(e),s=0;s<e;s++)t[s]=arguments[s];return this.call("text",t)}empty(){for(var e=arguments.length,t=new Array(e),s=0;s<e;s++)t[s]=arguments[s];return this.call("empty",t)}remove(){for(var e=arguments.length,t=new Array(e),s=0;s<e;s++)t[s]=arguments[s];return this.call("remove",t)}addClass(){for(var e=arguments.length,t=new Array(e),s=0;s<e;s++)t[s]=arguments[s];return this.call("addClass",t)}removeClass(){for(var e=arguments.length,t=new Array(e),s=0;s<e;s++)t[s]=arguments[s];return this.call("removeClass",t)}removeAllClasses(){for(var e=arguments.length,t=new Array(e),s=0;s<e;s++)t[s]=arguments[s];return this.call("removeAllClasses",t)}animate(){for(var e=arguments.length,t=new Array(e),s=0;s<e;s++)t[s]=arguments[s];return this.call("animate",t)}
/**
   * @param nodeList An Array of SVG DOM nodes or a SVG DOM NodeList (as returned by document.querySelectorAll)
   */constructor(e){this.svgElements=[];for(let t=0;t<e.length;t++)this.svgElements.push(new Svg(e[t]))}}const V={easeInSine:[.47,0,.745,.715],easeOutSine:[.39,.575,.565,1],easeInOutSine:[.445,.05,.55,.95],easeInQuad:[.55,.085,.68,.53],easeOutQuad:[.25,.46,.45,.94],easeInOutQuad:[.455,.03,.515,.955],easeInCubic:[.55,.055,.675,.19],easeOutCubic:[.215,.61,.355,1],easeInOutCubic:[.645,.045,.355,1],easeInQuart:[.895,.03,.685,.22],easeOutQuart:[.165,.84,.44,1],easeInOutQuart:[.77,0,.175,1],easeInQuint:[.755,.05,.855,.06],easeOutQuint:[.23,1,.32,1],easeInOutQuint:[.86,0,.07,1],easeInExpo:[.95,.05,.795,.035],easeOutExpo:[.19,1,.22,1],easeInOutExpo:[1,0,0,1],easeInCirc:[.6,.04,.98,.335],easeOutCirc:[.075,.82,.165,1],easeInOutCirc:[.785,.135,.15,.86],easeInBack:[.6,-.28,.735,.045],easeOutBack:[.175,.885,.32,1.275],easeInOutBack:[.68,-.55,.265,1.55]};function R(e,t,s){let r=arguments.length>3&&arguments[3]!==void 0&&arguments[3],a=arguments.length>4?arguments[4]:void 0;const{easing:o,...l}=s;const c={};let h;let u;o&&(h=Array.isArray(o)?o:V[o]);l.begin=i(l.begin,"ms");l.dur=i(l.dur,"ms");if(h){l.calcMode="spline";l.keySplines=h.join(" ");l.keyTimes="0;1"}if(r){l.fill="freeze";c[t]=l.from;e.attr(c);u=n(l.begin||0).value;l.begin="indefinite"}const d=e.elem("animate",{attributeName:t,...l});r&&setTimeout((()=>{try{d._node.beginElement()}catch(s){c[t]=l.to;e.attr(c);d.remove()}}),u);const m=d.getNode();a&&m.addEventListener("beginEvent",(()=>a.emit("animationBegin",{element:e,animate:m,params:s})));m.addEventListener("endEvent",(()=>{a&&a.emit("animationEnd",{element:e,animate:m,params:s});if(r){c[t]=l.to;e.attr(c);d.remove()}}))}class Svg{attr(t,s){if(typeof t==="string")return s?this._node.getAttributeNS(s,t):this._node.getAttribute(t);Object.keys(t).forEach((s=>{if(t[s]!==void 0)if(s.indexOf(":")!==-1){const i=s.split(":");this._node.setAttributeNS(e[i[0]],s,String(t[s]))}else this._node.setAttribute(s,String(t[s]))}));return this}
/**
   * Create a new SVG element whose wrapper object will be selected for further operations. This way you can also create nested groups easily.
   * @param name The name of the SVG element that should be created as child element of the currently selected element wrapper
   * @param attributes An object with properties that will be added as attributes to the SVG element that is created. Attributes with undefined values will not be added.
   * @param className This class or class list will be added to the SVG element
   * @param insertFirst If this param is set to true in conjunction with a parent element the newly created element will be added as first child element in the parent element
   * @return Returns a Svg wrapper object that can be used to modify the containing SVG data
   */elem(e,t,s){let i=arguments.length>3&&arguments[3]!==void 0&&arguments[3];return new Svg(e,t,s,this,i)}parent(){return this._node.parentNode instanceof SVGElement?new Svg(this._node.parentNode):null}root(){let e=this._node;while(e.nodeName!=="svg"){if(!e.parentElement)break;e=e.parentElement}return new Svg(e)}
/**
   * Find the first child SVG element of the current element that matches a CSS selector. The returned object is a Svg wrapper.
   * @param selector A CSS selector that is used to query for child SVG elements
   * @return The SVG wrapper for the element found or null if no element was found
   */querySelector(e){const t=this._node.querySelector(e);return t?new Svg(t):null}
/**
   * Find the all child SVG elements of the current element that match a CSS selector. The returned object is a Svg.List wrapper.
   * @param selector A CSS selector that is used to query for child SVG elements
   * @return The SVG wrapper list for the element found or null if no element was found
   */querySelectorAll(e){const t=this._node.querySelectorAll(e);return new SvgList(t)}getNode(){return this._node}
/**
   * This method creates a foreignObject (see https://developer.mozilla.org/en-US/docs/Web/SVG/Element/foreignObject) that allows to embed HTML content into a SVG graphic. With the help of foreignObjects you can enable the usage of regular HTML elements inside of SVG where they are subject for SVG positioning and transformation but the Browser will use the HTML rendering capabilities for the containing DOM.
   * @param content The DOM Node, or HTML string that will be converted to a DOM Node, that is then placed into and wrapped by the foreignObject
   * @param attributes An object with properties that will be added as attributes to the foreignObject element that is created. Attributes with undefined values will not be added.
   * @param className This class or class list will be added to the SVG element
   * @param insertFirst Specifies if the foreignObject should be inserted as first child
   * @return New wrapper object that wraps the foreignObject element
   */foreignObject(t,s,i){let n=arguments.length>3&&arguments[3]!==void 0&&arguments[3];let r;if(typeof t==="string"){const e=document.createElement("div");e.innerHTML=t;r=e.firstChild}else r=t;r instanceof Element&&r.setAttribute("xmlns",e.xmlns);const a=this.elem("foreignObject",s,i,n);a._node.appendChild(r);return a}
/**
   * This method adds a new text element to the current Svg wrapper.
   * @param t The text that should be added to the text element that is created
   * @return The same wrapper object that was used to add the newly created element
   */text(e){this._node.appendChild(document.createTextNode(e));return this}empty(){while(this._node.firstChild)this._node.removeChild(this._node.firstChild);return this}remove(){var e;(e=this._node.parentNode)===null||e===void 0?void 0:e.removeChild(this._node);return this.parent()}
/**
   * This method will replace the element with a new element that can be created outside of the current DOM.
   * @param newElement The new Svg object that will be used to replace the current wrapper object
   * @return The wrapper of the new element
   */replace(e){var t;(t=this._node.parentNode)===null||t===void 0?void 0:t.replaceChild(e._node,this._node);return e}
/**
   * This method will append an element to the current element as a child.
   * @param element The Svg element that should be added as a child
   * @param insertFirst Specifies if the element should be inserted as first child
   * @return The wrapper of the appended object
   */append(e){let t=arguments.length>1&&arguments[1]!==void 0&&arguments[1];t&&this._node.firstChild?this._node.insertBefore(e._node,this._node.firstChild):this._node.appendChild(e._node);return this}classes(){const e=this._node.getAttribute("class");return e?e.trim().split(/\s+/):[]}
/**
   * Adds one or a space separated list of classes to the current element and ensures the classes are only existing once.
   * @param names A white space separated list of class names
   * @return The wrapper of the current element
   */addClass(e){this._node.setAttribute("class",this.classes().concat(e.trim().split(/\s+/)).filter((function(e,t,s){return s.indexOf(e)===t})).join(" "));return this}
/**
   * Removes one or a space separated list of classes from the current element.
   * @param names A white space separated list of class names
   * @return The wrapper of the current element
   */removeClass(e){const t=e.trim().split(/\s+/);this._node.setAttribute("class",this.classes().filter((e=>t.indexOf(e)===-1)).join(" "));return this}removeAllClasses(){this._node.setAttribute("class","");return this}height(){return this._node.clientHeight}width(){return this._node.clientWidth}
/**
   * The animate function lets you animate the current element with SMIL animations. You can add animations for multiple attributes at the same time by using an animation definition object. This object should contain SMIL animation attributes. Please refer to http://www.w3.org/TR/SVG/animate.html for a detailed specification about the available animation attributes. Additionally an easing property can be passed in the animation definition object. This can be a string with a name of an easing function in `Svg.Easing` or an array with four numbers specifying a cubic Bézier curve.
   * **An animations object could look like this:**
   * ```javascript
   * element.animate({
   *   opacity: {
   *     dur: 1000,
   *     from: 0,
   *     to: 1
   *   },
   *   x1: {
   *     dur: '1000ms',
   *     from: 100,
   *     to: 200,
   *     easing: 'easeOutQuart'
   *   },
   *   y1: {
   *     dur: '2s',
   *     from: 0,
   *     to: 100
   *   }
   * });
   * ```
   * **Automatic unit conversion**
   * For the `dur` and the `begin` animate attribute you can also omit a unit by passing a number. The number will automatically be converted to milli seconds.
   * **Guided mode**
   * The default behavior of SMIL animations with offset using the `begin` attribute is that the attribute will keep it's original value until the animation starts. Mostly this behavior is not desired as you'd like to have your element attributes already initialized with the animation `from` value even before the animation starts. Also if you don't specify `fill="freeze"` on an animate element or if you delete the animation after it's done (which is done in guided mode) the attribute will switch back to the initial value. This behavior is also not desired when performing simple one-time animations. For one-time animations you'd want to trigger animations immediately instead of relative to the document begin time. That's why in guided mode Svg will also use the `begin` property to schedule a timeout and manually start the animation after the timeout. If you're using multiple SMIL definition objects for an attribute (in an array), guided mode will be disabled for this attribute, even if you explicitly enabled it.
   * If guided mode is enabled the following behavior is added:
   * - Before the animation starts (even when delayed with `begin`) the animated attribute will be set already to the `from` value of the animation
   * - `begin` is explicitly set to `indefinite` so it can be started manually without relying on document begin time (creation)
   * - The animate element will be forced to use `fill="freeze"`
   * - The animation will be triggered with `beginElement()` in a timeout where `begin` of the definition object is interpreted in milli seconds. If no `begin` was specified the timeout is triggered immediately.
   * - After the animation the element attribute value will be set to the `to` value of the animation
   * - The animate element is deleted from the DOM
   * @param animations An animations object where the property keys are the attributes you'd like to animate. The properties should be objects again that contain the SMIL animation attributes (usually begin, dur, from, and to). The property begin and dur is auto converted (see Automatic unit conversion). You can also schedule multiple animations for the same attribute by passing an Array of SMIL definition objects. Attributes that contain an array of SMIL definition objects will not be executed in guided mode.
   * @param guided Specify if guided mode should be activated for this animation (see Guided mode). If not otherwise specified, guided mode will be activated.
   * @param eventEmitter If specified, this event emitter will be notified when an animation starts or ends.
   * @return The current element where the animation was added
   */animate(e){let t=!(arguments.length>1&&arguments[1]!==void 0)||arguments[1],s=arguments.length>2?arguments[2]:void 0;Object.keys(e).forEach((i=>{const n=e[i];Array.isArray(n)?n.forEach((e=>R(this,i,e,false,s))):R(this,i,n,t,s)}));return this}
/**
   * @param name The name of the SVG element to create or an SVG dom element which should be wrapped into Svg
   * @param attributes An object with properties that will be added as attributes to the SVG element that is created. Attributes with undefined values will not be added.
   * @param className This class or class list will be added to the SVG element
   * @param parent The parent SVG wrapper object where this newly created wrapper and it's element will be attached to as child
   * @param insertFirst If this param is set to true in conjunction with a parent element the newly created element will be added as first child element in the parent element
   */constructor(t,s,i,n,r=false){if(t instanceof Element)this._node=t;else{this._node=document.createElementNS(e.svg,t);t==="svg"&&this.attr({"xmlns:ct":e.ct})}s&&this.attr(s);i&&this.addClass(i);n&&(r&&n._node.firstChild?n._node.insertBefore(this._node,n._node.firstChild):n._node.appendChild(this._node))}}
/**
   * @todo Only there for chartist <1 compatibility. Remove after deprecation warining.
   * @deprecated Use the animation module export `easings` directly.
   */Svg.Easing=V;
/**
 * Create or reinitialize the SVG element for the chart
 * @param container The containing DOM Node object that will be used to plant the SVG element
 * @param width Set the width of the SVG element. Default is 100%
 * @param height Set the height of the SVG element. Default is 100%
 * @param className Specify a class to be added to the SVG element
 * @return The created/reinitialized SVG element
 */function G(t){let s=arguments.length>1&&arguments[1]!==void 0?arguments[1]:"100%",i=arguments.length>2&&arguments[2]!==void 0?arguments[2]:"100%",n=arguments.length>3?arguments[3]:void 0,r=arguments.length>4?arguments[4]:void 0;if(!t)throw new Error("Container element is not found");Array.from(t.querySelectorAll("svg")).filter((t=>t.getAttributeNS(e.xmlns,"ct"))).forEach((e=>t.removeChild(e)));const a=new Svg("svg").attr({width:s,height:i}).attr({style:"width: ".concat(s,"; height: ").concat(i,";")});n&&a.addClass(n);r&&a.attr({viewBox:"0 0 ".concat(r.width," ").concat(r.height)});t.appendChild(a.getNode());return a}
/**
 * Converts a number into a padding object.
 * @param padding
 * @param fallback This value is used to fill missing values if a incomplete padding object was passed
 * @returns Returns a padding object containing top, right, bottom, left properties filled with the padding number passed in as argument. If the argument is something else than a number (presumably already a correct padding object) then this argument is directly returned.
 */function D(e){return typeof e==="number"?{top:e,right:e,bottom:e,left:e}:e===void 0?{top:0,right:0,bottom:0,left:0}:{top:typeof e.top==="number"?e.top:0,right:typeof e.right==="number"?e.right:0,bottom:typeof e.bottom==="number"?e.bottom:0,left:typeof e.left==="number"?e.left:0}}
/**
 * Initialize chart drawing rectangle (area where chart is drawn) x1,y1 = bottom left / x2,y2 = top right
 * @param svg The svg element for the chart
 * @param options The Object that contains all the optional values for the chart
 * @return The chart rectangles coordinates inside the svg element plus the rectangles measurements
 */function U(e,t){var s,i,r,a,o,l;const c=Boolean(t.axisX||t.axisY);const h=((s=t.axisY)===null||s===void 0?void 0:s.offset)||0;const u=((i=t.axisX)===null||i===void 0?void 0:i.offset)||0;const d=(r=t.axisY)===null||r===void 0?void 0:r.position;const m=(a=t.axisX)===null||a===void 0?void 0:a.position;let f=((o=t.viewBox)===null||o===void 0?void 0:o.width)||e.width()||n(t.width).value||0;let p=((l=t.viewBox)===null||l===void 0?void 0:l.height)||e.height()||n(t.height).value||0;const g=D(t.chartPadding);f=Math.max(f,h+g.left+g.right);p=Math.max(p,u+g.top+g.bottom);const v={x1:0,x2:0,y1:0,y2:0,padding:g,width(){return this.x2-this.x1},height(){return this.y1-this.y2}};if(c){if(m==="start"){v.y2=g.top+u;v.y1=Math.max(p-g.bottom,v.y2+1)}else{v.y2=g.top;v.y1=Math.max(p-g.bottom-u,v.y2+1)}if(d==="start"){v.x1=g.left+h;v.x2=Math.max(f-g.right,v.x1+1)}else{v.x1=g.left;v.x2=Math.max(f-g.right-h,v.x1+1)}}else{v.x1=g.left;v.x2=Math.max(f-g.right,v.x1+1);v.y2=g.top;v.y1=Math.max(p-g.bottom,v.y2+1)}return v}function H(e,t,s,i,n,r,a,o){const l={["".concat(s.units.pos,"1")]:e,["".concat(s.units.pos,"2")]:e,["".concat(s.counterUnits.pos,"1")]:i,["".concat(s.counterUnits.pos,"2")]:i+n};const c=r.elem("line",l,a.join(" "));o.emit("draw",{type:"grid",axis:s,index:t,group:r,element:c,...l})}function T(e,t,s,i){const n=e.elem("rect",{x:t.x1,y:t.y2,width:t.width(),height:t.height()},s,true);i.emit("draw",{type:"gridBackground",group:e,element:n})}function Q(e,t,s,i,n,r,a,o,l,c){const h={[n.units.pos]:e+a[n.units.pos],[n.counterUnits.pos]:a[n.counterUnits.pos],[n.units.len]:t,[n.counterUnits.len]:Math.max(0,r-10)};const u=Math.round(h[n.units.len]);const d=Math.round(h[n.counterUnits.len]);const m=document.createElement("span");m.className=l.join(" ");m.style[n.units.len]=u+"px";m.style[n.counterUnits.len]=d+"px";m.textContent=String(i);const f=o.foreignObject(m,{style:"overflow: visible;",...h});c.emit("draw",{type:"label",axis:n,index:s,group:o,element:f,text:i,...h})}
/**
 * Provides options handling functionality with callback for options changes triggered by responsive options and media query matches
 * @param options Options set by user
 * @param responsiveOptions Optional functions to add responsive behavior to chart
 * @param eventEmitter The event emitter that will be used to emit the options changed events
 * @return The consolidated options object from the defaults, base and matching responsive options
 */function F(e,t,s){let i;const n=[];function r(n){const r=i;i=m({},e);t&&t.forEach((e=>{const t=window.matchMedia(e[0]);t.matches&&(i=m({},i,e[1]))}));s&&n&&s.emit("optionsChanged",{previousOptions:r,currentOptions:i})}function a(){n.forEach((e=>e.removeEventListener("change",r)))}if(!window.matchMedia)throw new Error("window.matchMedia not found! Make sure you're using a polyfill.");t&&t.forEach((e=>{const t=window.matchMedia(e[0]);t.addEventListener("change",r);n.push(t)}));r();return{removeMediaQueryListeners:a,getCurrentOptions(){return i}}}const q={m:["x","y"],l:["x","y"],c:["x1","y1","x2","y2","x","y"],a:["rx","ry","xAr","lAf","sf","x","y"]};const W={accuracy:3};function Z(e,t,s,i,n,r){const a={command:n?e.toLowerCase():e.toUpperCase(),...t,...r?{data:r}:{}};s.splice(i,0,a)}function $(e,t){e.forEach(((s,i)=>{q[s.command.toLowerCase()].forEach(((n,r)=>{t(s,n,i,r,e)}))}))}class SvgPath{
/**
   * This static function on `SvgPath` is joining multiple paths together into one paths.
   * @param paths A list of paths to be joined together. The order is important.
   * @param close If the newly created path should be a closed path
   * @param options Path options for the newly created path.
   */
static join(e){let t=arguments.length>1&&arguments[1]!==void 0&&arguments[1],s=arguments.length>2?arguments[2]:void 0;const i=new SvgPath(t,s);for(let t=0;t<e.length;t++){const s=e[t];for(let e=0;e<s.pathElements.length;e++)i.pathElements.push(s.pathElements[e])}return i}position(e){if(e!==void 0){this.pos=Math.max(0,Math.min(this.pathElements.length,e));return this}return this.pos}
/**
   * Removes elements from the path starting at the current position.
   * @param count Number of path elements that should be removed from the current position.
   * @return The current path object for easy call chaining.
   */remove(e){this.pathElements.splice(this.pos,e);return this}
/**
   * Use this function to add a new move SVG path element.
   * @param x The x coordinate for the move element.
   * @param y The y coordinate for the move element.
   * @param relative If set to true the move element will be created with relative coordinates (lowercase letter)
   * @param data Any data that should be stored with the element object that will be accessible in pathElement
   * @return The current path object for easy call chaining.
   */move(e,t){let s=arguments.length>2&&arguments[2]!==void 0&&arguments[2],i=arguments.length>3?arguments[3]:void 0;Z("M",{x:+e,y:+t},this.pathElements,this.pos++,s,i);return this}
/**
   * Use this function to add a new line SVG path element.
   * @param x The x coordinate for the line element.
   * @param y The y coordinate for the line element.
   * @param relative If set to true the line element will be created with relative coordinates (lowercase letter)
   * @param data Any data that should be stored with the element object that will be accessible in pathElement
   * @return The current path object for easy call chaining.
   */line(e,t){let s=arguments.length>2&&arguments[2]!==void 0&&arguments[2],i=arguments.length>3?arguments[3]:void 0;Z("L",{x:+e,y:+t},this.pathElements,this.pos++,s,i);return this}
/**
   * Use this function to add a new curve SVG path element.
   * @param x1 The x coordinate for the first control point of the bezier curve.
   * @param y1 The y coordinate for the first control point of the bezier curve.
   * @param x2 The x coordinate for the second control point of the bezier curve.
   * @param y2 The y coordinate for the second control point of the bezier curve.
   * @param x The x coordinate for the target point of the curve element.
   * @param y The y coordinate for the target point of the curve element.
   * @param relative If set to true the curve element will be created with relative coordinates (lowercase letter)
   * @param data Any data that should be stored with the element object that will be accessible in pathElement
   * @return The current path object for easy call chaining.
   */curve(e,t,s,i,n,r){let a=arguments.length>6&&arguments[6]!==void 0&&arguments[6],o=arguments.length>7?arguments[7]:void 0;Z("C",{x1:+e,y1:+t,x2:+s,y2:+i,x:+n,y:+r},this.pathElements,this.pos++,a,o);return this}
/**
   * Use this function to add a new non-bezier curve SVG path element.
   * @param rx The radius to be used for the x-axis of the arc.
   * @param ry The radius to be used for the y-axis of the arc.
   * @param xAr Defines the orientation of the arc
   * @param lAf Large arc flag
   * @param sf Sweep flag
   * @param x The x coordinate for the target point of the curve element.
   * @param y The y coordinate for the target point of the curve element.
   * @param relative If set to true the curve element will be created with relative coordinates (lowercase letter)
   * @param data Any data that should be stored with the element object that will be accessible in pathElement
   * @return The current path object for easy call chaining.
   */arc(e,t,s,i,n,r,a){let o=arguments.length>7&&arguments[7]!==void 0&&arguments[7],l=arguments.length>8?arguments[8]:void 0;Z("A",{rx:e,ry:t,xAr:s,lAf:i,sf:n,x:r,y:a},this.pathElements,this.pos++,o,l);return this}
/**
   * Parses an SVG path seen in the d attribute of path elements, and inserts the parsed elements into the existing path object at the current cursor position. Any closing path indicators (Z at the end of the path) will be ignored by the parser as this is provided by the close option in the options of the path object.
   * @param path Any SVG path that contains move (m), line (l) or curve (c) components.
   * @return The current path object for easy call chaining.
   */parse(e){const t=e.replace(/([A-Za-z])(-?[0-9])/g,"$1 $2").replace(/([0-9])([A-Za-z])/g,"$1 $2").split(/[\s,]+/).reduce(((e,t)=>{t.match(/[A-Za-z]/)&&e.push([]);e[e.length-1].push(t);return e}),[]);t[t.length-1][0].toUpperCase()==="Z"&&t.pop();const s=t.map((e=>{const t=e.shift();const s=q[t.toLowerCase()];return{command:t,...s.reduce(((t,s,i)=>{t[s]=+e[i];return t}),{})}}));this.pathElements.splice(this.pos,0,...s);this.pos+=s.length;return this}stringify(){const e=Math.pow(10,this.options.accuracy);return this.pathElements.reduce(((t,s)=>{const i=q[s.command.toLowerCase()].map((t=>{const i=s[t];return this.options.accuracy?Math.round(i*e)/e:i}));return t+s.command+i.join(",")}),"")+(this.close?"Z":"")}
/**
   * Scales all elements in the current SVG path object. There is an individual parameter for each coordinate. Scaling will also be done for control points of curves, affecting the given coordinate.
   * @param x The number which will be used to scale the x, x1 and x2 of all path elements.
   * @param y The number which will be used to scale the y, y1 and y2 of all path elements.
   * @return The current path object for easy call chaining.
   */scale(e,t){$(this.pathElements,((s,i)=>{s[i]*=i[0]==="x"?e:t}));return this}
/**
   * Translates all elements in the current SVG path object. The translation is relative and there is an individual parameter for each coordinate. Translation will also be done for control points of curves, affecting the given coordinate.
   * @param x The number which will be used to translate the x, x1 and x2 of all path elements.
   * @param y The number which will be used to translate the y, y1 and y2 of all path elements.
   * @return The current path object for easy call chaining.
   */translate(e,t){$(this.pathElements,((s,i)=>{s[i]+=i[0]==="x"?e:t}));return this}
/**
   * This function will run over all existing path elements and then loop over their attributes. The callback function will be called for every path element attribute that exists in the current path.
   * The method signature of the callback function looks like this:
   * ```javascript
   * function(pathElement, paramName, pathElementIndex, paramIndex, pathElements)
   * ```
   * If something else than undefined is returned by the callback function, this value will be used to replace the old value. This allows you to build custom transformations of path objects that can't be achieved using the basic transformation functions scale and translate.
   * @param transformFnc The callback function for the transformation. Check the signature in the function description.
   * @return The current path object for easy call chaining.
   */transform(e){$(this.pathElements,((t,s,i,n,r)=>{const a=e(t,s,i,n,r);(a||a===0)&&(t[s]=a)}));return this}
/**
   * This function clones a whole path object with all its properties. This is a deep clone and path element objects will also be cloned.
   * @param close Optional option to set the new cloned path to closed. If not specified or false, the original path close option will be used.
   */clone(){let e=arguments.length>0&&arguments[0]!==void 0&&arguments[0];const t=new SvgPath(e||this.close);t.pos=this.pos;t.pathElements=this.pathElements.slice().map((e=>({...e})));t.options={...this.options};return t}
/**
   * Split a Svg.Path object by a specific command in the path chain. The path chain will be split and an array of newly created paths objects will be returned. This is useful if you'd like to split an SVG path by it's move commands, for example, in order to isolate chunks of drawings.
   * @param command The command you'd like to use to split the path
   */splitByCommand(e){const t=[new SvgPath];this.pathElements.forEach((s=>{s.command===e.toUpperCase()&&t[t.length-1].pathElements.length!==0&&t.push(new SvgPath);t[t.length-1].pathElements.push(s)}));return t}
/**
   * Used to construct a new path object.
   * @param close If set to true then this path will be closed when stringified (with a Z at the end)
   * @param options Options object that overrides the default objects. See default options for more details.
   */constructor(e=false,t){this.close=e;this.pathElements=[];this.pos=0;this.options={...W,...t}}}function J(e){const t={fillHoles:false,...e};return function(e,s){const i=new SvgPath;let n=true;for(let r=0;r<e.length;r+=2){const a=e[r];const o=e[r+1];const l=s[r/2];if(L(l.value)!==void 0){n?i.move(a,o,false,l):i.line(a,o,false,l);n=false}else t.fillHoles||(n=true)}return i}}
/**
 * Simple smoothing creates horizontal handles that are positioned with a fraction of the length between two data points. You can use the divisor option to specify the amount of smoothing.
 *
 * Simple smoothing can be used instead of `Chartist.Smoothing.cardinal` if you'd like to get rid of the artifacts it produces sometimes. Simple smoothing produces less flowing lines but is accurate by hitting the points and it also doesn't swing below or above the given data point.
 *
 * All smoothing functions within Chartist are factory functions that accept an options parameter. The simple interpolation function accepts one configuration parameter `divisor`, between 1 and ∞, which controls the smoothing characteristics.
 *
 * @example
 * ```ts
 * const chart = new LineChart('.ct-chart', {
 *   labels: [1, 2, 3, 4, 5],
 *   series: [[1, 2, 8, 1, 7]]
 * }, {
 *   lineSmooth: Interpolation.simple({
 *     divisor: 2,
 *     fillHoles: false
 *   })
 * });
 * ```
 *
 * @param options The options of the simple interpolation factory function.
 */function K(e){const t={divisor:2,fillHoles:false,...e};const s=1/Math.max(1,t.divisor);return function(e,i){const n=new SvgPath;let r=0;let a=0;let o;for(let l=0;l<e.length;l+=2){const c=e[l];const h=e[l+1];const u=(c-r)*s;const d=i[l/2];if(d.value!==void 0){o===void 0?n.move(c,h,false,d):n.curve(r+u,a,c-u,h,c,h,false,d);r=c;a=h;o=d}else if(!t.fillHoles){r=a=0;o=void 0}}return n}}function ee(e){const t={postpone:true,fillHoles:false,...e};return function(e,s){const i=new SvgPath;let n=0;let r=0;let a;for(let o=0;o<e.length;o+=2){const l=e[o];const c=e[o+1];const h=s[o/2];if(h.value!==void 0){if(a===void 0)i.move(l,c,false,h);else{t.postpone?i.line(l,r,false,a):i.line(n,c,false,h);i.line(l,c,false,h)}n=l;r=c;a=h}else if(!t.fillHoles){n=r=0;a=void 0}}return i}}
/**
 * Cardinal / Catmull-Rome spline interpolation is the default smoothing function in Chartist. It produces nice results where the splines will always meet the points. It produces some artifacts though when data values are increased or decreased rapidly. The line may not follow a very accurate path and if the line should be accurate this smoothing function does not produce the best results.
 *
 * Cardinal splines can only be created if there are more than two data points. If this is not the case this smoothing will fallback to `Chartist.Smoothing.none`.
 *
 * All smoothing functions within Chartist are factory functions that accept an options parameter. The cardinal interpolation function accepts one configuration parameter `tension`, between 0 and 1, which controls the smoothing intensity.
 *
 * @example
 * ```ts
 * const chart = new LineChart('.ct-chart', {
 *   labels: [1, 2, 3, 4, 5],
 *   series: [[1, 2, 8, 1, 7]]
 * }, {
 *   lineSmooth: Interpolation.cardinal({
 *     tension: 1,
 *     fillHoles: false
 *   })
 * });
 * ```
 *
 * @param options The options of the cardinal factory function.
 */function te(e){const t={tension:1,fillHoles:false,...e};const s=Math.min(1,Math.max(0,t.tension));const i=1-s;return function e(n,r){const a=z(n,r,{fillHoles:t.fillHoles});if(a.length){if(a.length>1)return SvgPath.join(a.map((t=>e(t.pathCoordinates,t.valueData))));{n=a[0].pathCoordinates;r=a[0].valueData;if(n.length<=4)return J()(n,r);const e=(new SvgPath).move(n[0],n[1],false,r[0]);const t=false;for(let a=0,o=n.length;o-2*Number(!t)>a;a+=2){const t=[{x:+n[a-2],y:+n[a-1]},{x:+n[a],y:+n[a+1]},{x:+n[a+2],y:+n[a+3]},{x:+n[a+4],y:+n[a+5]}];o-4===a?t[3]=t[2]:a||(t[0]={x:+n[a],y:+n[a+1]});e.curve(s*(-t[0].x+6*t[1].x+t[2].x)/6+i*t[2].x,s*(-t[0].y+6*t[1].y+t[2].y)/6+i*t[2].y,s*(t[1].x+6*t[2].x-t[3].x)/6+i*t[2].x,s*(t[1].y+6*t[2].y-t[3].y)/6+i*t[2].y,t[2].x,t[2].y,false,r[(a+2)/2])}return e}}return J()([],[])}}
/**
 * Monotone Cubic spline interpolation produces a smooth curve which preserves monotonicity. Unlike cardinal splines, the curve will not extend beyond the range of y-values of the original data points.
 *
 * Monotone Cubic splines can only be created if there are more than two data points. If this is not the case this smoothing will fallback to `Chartist.Smoothing.none`.
 *
 * The x-values of subsequent points must be increasing to fit a Monotone Cubic spline. If this condition is not met for a pair of adjacent points, then there will be a break in the curve between those data points.
 *
 * All smoothing functions within Chartist are factory functions that accept an options parameter.
 *
 * @example
 * ```ts
 * const chart = new LineChart('.ct-chart', {
 *   labels: [1, 2, 3, 4, 5],
 *   series: [[1, 2, 8, 1, 7]]
 * }, {
 *   lineSmooth: Interpolation.monotoneCubic({
 *     fillHoles: false
 *   })
 * });
 * ```
 *
 * @param options The options of the monotoneCubic factory function.
 */function se(e){const t={fillHoles:false,...e};return function e(s,i){const n=z(s,i,{fillHoles:t.fillHoles,increasingX:true});if(n.length){if(n.length>1)return SvgPath.join(n.map((t=>e(t.pathCoordinates,t.valueData))));{s=n[0].pathCoordinates;i=n[0].valueData;if(s.length<=4)return J()(s,i);const e=[];const t=[];const r=s.length/2;const a=[];const o=[];const l=[];const c=[];for(let i=0;i<r;i++){e[i]=s[i*2];t[i]=s[i*2+1]}for(let s=0;s<r-1;s++){l[s]=t[s+1]-t[s];c[s]=e[s+1]-e[s];o[s]=l[s]/c[s]}a[0]=o[0];a[r-1]=o[r-2];for(let e=1;e<r-1;e++)if(o[e]===0||o[e-1]===0||o[e-1]>0!==o[e]>0)a[e]=0;else{a[e]=3*(c[e-1]+c[e])/((2*c[e]+c[e-1])/o[e-1]+(c[e]+2*c[e-1])/o[e]);isFinite(a[e])||(a[e]=0)}const h=(new SvgPath).move(e[0],t[0],false,i[0]);for(let s=0;s<r-1;s++)h.curve(e[s]+c[s]/3,t[s]+a[s]*c[s]/3,e[s+1]-c[s]/3,t[s+1]-a[s+1]*c[s]/3,e[s+1],t[s+1],false,i[s+1]);return h}}return J()([],[])}}var ie=Object.freeze({__proto__:null,none:J,simple:K,step:ee,cardinal:te,monotoneCubic:se});class EventEmitter{on(e,t){const{allListeners:s,listeners:i}=this;if(e==="*")s.add(t);else{i.has(e)||i.set(e,new Set);i.get(e).add(t)}}off(e,t){const{allListeners:s,listeners:i}=this;if(e==="*")t?s.delete(t):s.clear();else if(i.has(e)){const s=i.get(e);t?s.delete(t):s.clear();s.size||i.delete(e)}}
/**
   * Use this function to emit an event. All handlers that are listening for this event will be triggered with the data parameter.
   * @param event The event name that should be triggered
   * @param data Arbitrary data that will be passed to the event handler callback functions
   */emit(e,t){const{allListeners:s,listeners:i}=this;i.has(e)&&i.get(e).forEach((e=>e(t)));s.forEach((s=>s(e,t)))}constructor(){this.listeners=new Map;this.allListeners=new Set}}const ne=new WeakMap;class BaseChart{
/**
   * Updates the chart which currently does a full reconstruction of the SVG DOM
   * @param data Optional data you'd like to set for the chart before it will update. If not specified the update method will use the data that is already configured with the chart.
   * @param options Optional options you'd like to add to the previous options for the chart before it will update. If not specified the update method will use the options that have been already configured with the chart.
   * @param override If set to true, the passed options will be used to extend the options that have been configured already. Otherwise the chart default options will be used as the base
   */
update(e,t){let s=arguments.length>2&&arguments[2]!==void 0&&arguments[2];if(e){this.data=e||{};this.data.labels=this.data.labels||[];this.data.series=this.data.series||[];this.eventEmitter.emit("data",{type:"update",data:this.data})}if(t){this.options=m({},s?this.options:this.defaultOptions,t);if(!this.initializeTimeoutId){var i;(i=this.optionsProvider)===null||i===void 0?void 0:i.removeMediaQueryListeners();this.optionsProvider=F(this.options,this.responsiveOptions,this.eventEmitter)}}!this.initializeTimeoutId&&this.optionsProvider&&this.createChart(this.optionsProvider.getCurrentOptions());return this}detach(){if(this.initializeTimeoutId)window.clearTimeout(this.initializeTimeoutId);else{var e;window.removeEventListener("resize",this.resizeListener);(e=this.optionsProvider)===null||e===void 0?void 0:e.removeMediaQueryListeners()}ne.delete(this.container);return this}on(e,t){this.eventEmitter.on(e,t);return this}off(e,t){this.eventEmitter.off(e,t);return this}initialize(){window.addEventListener("resize",this.resizeListener);this.optionsProvider=F(this.options,this.responsiveOptions,this.eventEmitter);this.eventEmitter.on("optionsChanged",(()=>this.update()));this.options.plugins&&this.options.plugins.forEach((e=>{Array.isArray(e)?e[0](this,e[1]):e(this)}));this.eventEmitter.emit("data",{type:"initial",data:this.data});this.createChart(this.optionsProvider.getCurrentOptions());this.initializeTimeoutId=null}constructor(e,t,s,i,n){this.data=t;this.defaultOptions=s;this.options=i;this.responsiveOptions=n;this.eventEmitter=new EventEmitter;this.resizeListener=()=>this.update();this.initializeTimeoutId=setTimeout((()=>this.initialize()),0);const r=typeof e==="string"?document.querySelector(e):e;if(!r)throw new Error("Target element ".concat(typeof e==="string"?'"'.concat(e,'"'):""," is not found"));this.container=r;const a=ne.get(r);a&&a.detach();ne.set(r,this)}}const re={x:{pos:"x",len:"width",dir:"horizontal",rectStart:"x1",rectEnd:"x2",rectOffset:"y2"},y:{pos:"y",len:"height",dir:"vertical",rectStart:"y2",rectEnd:"y1",rectOffset:"x1"}};class Axis{createGridAndLabels(e,t,s,i){const n=this.units.pos==="x"?s.axisX:s.axisY;const r=this.ticks.map(((e,t)=>this.projectValue(e,t)));const a=this.ticks.map(n.labelInterpolationFnc);r.forEach(((o,l)=>{const c=a[l];const h={x:0,y:0};let u;u=r[l+1]?r[l+1]-o:Math.max(this.axisLength-o,this.axisLength/this.ticks.length);if(c===""||!w(c)){if(this.units.pos==="x"){o=this.chartRect.x1+o;h.x=s.axisX.labelOffset.x;s.axisX.position==="start"?h.y=this.chartRect.padding.top+s.axisX.labelOffset.y+5:h.y=this.chartRect.y1+s.axisX.labelOffset.y+5}else{o=this.chartRect.y1-o;h.y=s.axisY.labelOffset.y-u;s.axisY.position==="start"?h.x=this.chartRect.padding.left+s.axisY.labelOffset.x:h.x=this.chartRect.x2+s.axisY.labelOffset.x+10}n.showGrid&&H(o,l,this,this.gridOffset,this.chartRect[this.counterUnits.len](),e,[s.classNames.grid,s.classNames[this.units.dir]],i);n.showLabel&&Q(o,u,l,c,this,n.offset,h,t,[s.classNames.label,s.classNames[this.units.dir],n.position==="start"?s.classNames[n.position]:s.classNames.end],i)}}))}constructor(e,t,s){this.units=e;this.chartRect=t;this.ticks=s;this.counterUnits=e===re.x?re.y:re.x;this.axisLength=t[this.units.rectEnd]-t[this.units.rectStart];this.gridOffset=t[this.units.rectOffset]}}class AutoScaleAxis extends Axis{projectValue(e){const t=Number(L(e,this.units.pos));return this.axisLength*(t-this.bounds.min)/this.bounds.range}constructor(e,t,s,i){const n=i.highLow||O(t,i,e.pos);const r=d(s[e.rectEnd]-s[e.rectStart],n,i.scaleMinSpace||20,i.onlyInteger);const a={min:r.min,max:r.max};super(e,s,r.values);this.bounds=r;this.range=a}}class FixedScaleAxis extends Axis{projectValue(e){const t=Number(L(e,this.units.pos));return this.axisLength*(t-this.range.min)/(this.range.max-this.range.min)}constructor(e,t,s,i){const n=i.highLow||O(t,i,e.pos);const r=i.divisor||1;const a=(i.ticks||p(r,(e=>n.low+(n.high-n.low)/r*e))).sort(((e,t)=>Number(e)-Number(t)));const o={min:n.low,max:n.high};super(e,s,a);this.range=o}}class StepAxis extends Axis{projectValue(e,t){return this.stepLength*t}constructor(e,t,s,i){const n=i.ticks||[];super(e,s,n);const r=Math.max(1,n.length-(i.stretch?1:0));this.stepLength=this.axisLength/r;this.stretch=Boolean(i.stretch)}}function ae(e,t,s){var i;if(x(e,"name")&&e.name&&((i=t.series)===null||i===void 0?void 0:i[e.name])){const i=t===null||t===void 0?void 0:t.series[e.name];const n=i[s];const r=n===void 0?t[s]:n;return r}return t[s]}const oe={axisX:{offset:30,position:"end",labelOffset:{x:0,y:0},showLabel:true,showGrid:true,labelInterpolationFnc:f,type:void 0},axisY:{offset:40,position:"start",labelOffset:{x:0,y:0},showLabel:true,showGrid:true,labelInterpolationFnc:f,type:void 0,scaleMinSpace:20,onlyInteger:false},width:void 0,height:void 0,showLine:true,showPoint:true,showArea:false,areaBase:0,lineSmooth:true,showGridBackground:false,low:void 0,high:void 0,chartPadding:{top:15,right:15,bottom:5,left:10},fullWidth:false,reverseData:false,classNames:{chart:"ct-chart-line",label:"ct-label",labelGroup:"ct-labels",series:"ct-series",line:"ct-line",point:"ct-point",area:"ct-area",grid:"ct-grid",gridGroup:"ct-grids",gridBackground:"ct-grid-background",vertical:"ct-vertical",horizontal:"ct-horizontal",start:"ct-start",end:"ct-end"}};class LineChart extends BaseChart{createChart(e){const{data:t}=this;const s=B(t,e.reverseData,true);const i=G(this.container,e.width,e.height,e.classNames.chart,e.viewBox);this.svg=i;const n=i.elem("g").addClass(e.classNames.gridGroup);const a=i.elem("g");const o=i.elem("g").addClass(e.classNames.labelGroup);const l=U(i,e);let c;let h;c=e.axisX.type===void 0?new StepAxis(re.x,s.series,l,{...e.axisX,ticks:s.labels,stretch:e.fullWidth}):new e.axisX.type(re.x,s.series,l,e.axisX);h=e.axisY.type===void 0?new AutoScaleAxis(re.y,s.series,l,{...e.axisY,high:y(e.high)?e.high:e.axisY.high,low:y(e.low)?e.low:e.axisY.low}):new e.axisY.type(re.y,s.series,l,e.axisY);c.createGridAndLabels(n,o,e,this.eventEmitter);h.createGridAndLabels(n,o,e,this.eventEmitter);e.showGridBackground&&T(n,l,e.classNames.gridBackground,this.eventEmitter);A(t.series,((t,i)=>{const n=a.elem("g");const o=x(t,"name")&&t.name;const u=x(t,"className")&&t.className;const d=x(t,"meta")?t.meta:void 0;o&&n.attr({"ct:series-name":o});d&&n.attr({"ct:meta":X(d)});n.addClass([e.classNames.series,u||"".concat(e.classNames.series,"-").concat(r(i))].join(" "));const m=[];const f=[];s.series[i].forEach(((e,n)=>{const r={x:l.x1+c.projectValue(e,n,s.series[i]),y:l.y1-h.projectValue(e,n,s.series[i])};m.push(r.x,r.y);f.push({value:e,valueIndex:n,meta:S(t,n)})}));const p={lineSmooth:ae(t,e,"lineSmooth"),showPoint:ae(t,e,"showPoint"),showLine:ae(t,e,"showLine"),showArea:ae(t,e,"showArea"),areaBase:ae(t,e,"areaBase")};let g;g=typeof p.lineSmooth==="function"?p.lineSmooth:p.lineSmooth?se():J();const v=g(m,f);p.showPoint&&v.pathElements.forEach((s=>{const{data:r}=s;const a=n.elem("line",{x1:s.x,y1:s.y,x2:s.x+.01,y2:s.y},e.classNames.point);if(r){let e;let t;x(r.value,"x")&&(e=r.value.x);x(r.value,"y")&&(t=r.value.y);a.attr({"ct:value":[e,t].filter(y).join(","),"ct:meta":X(r.meta)})}this.eventEmitter.emit("draw",{type:"point",value:r===null||r===void 0?void 0:r.value,index:(r===null||r===void 0?void 0:r.valueIndex)||0,meta:r===null||r===void 0?void 0:r.meta,series:t,seriesIndex:i,axisX:c,axisY:h,group:n,element:a,x:s.x,y:s.y,chartRect:l})}));if(p.showLine){const r=n.elem("path",{d:v.stringify()},e.classNames.line,true);this.eventEmitter.emit("draw",{type:"line",values:s.series[i],path:v.clone(),chartRect:l,index:i,series:t,seriesIndex:i,meta:d,axisX:c,axisY:h,group:n,element:r})}if(p.showArea&&h.range){const r=Math.max(Math.min(p.areaBase,h.range.max),h.range.min);const a=l.y1-h.projectValue(r);v.splitByCommand("M").filter((e=>e.pathElements.length>1)).map((e=>{const t=e.pathElements[0];const s=e.pathElements[e.pathElements.length-1];return e.clone(true).position(0).remove(1).move(t.x,a).line(t.x,t.y).position(e.pathElements.length+1).line(s.x,a)})).forEach((r=>{const a=n.elem("path",{d:r.stringify()},e.classNames.area,true);this.eventEmitter.emit("draw",{type:"area",values:s.series[i],path:r.clone(),series:t,seriesIndex:i,axisX:c,axisY:h,chartRect:l,index:i,group:n,element:a,meta:d})}))}}),e.reverseData);this.eventEmitter.emit("created",{chartRect:l,axisX:c,axisY:h,svg:i,options:e})}
/**
   * This method creates a new line chart.
   * @param query A selector query string or directly a DOM element
   * @param data The data object that needs to consist of a labels and a series array
   * @param options The options object with options that override the default options. Check the examples for a detailed list.
   * @param responsiveOptions Specify an array of responsive option arrays which are a media query and options object pair => [[mediaQueryString, optionsObject],[more...]]
   * @return An object which exposes the API for the created chart
   *
   * @example
   * ```ts
   * // Create a simple line chart
   * const data = {
   *   // A labels array that can contain any sort of values
   *   labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
   *   // Our series array that contains series objects or in this case series data arrays
   *   series: [
   *     [5, 2, 4, 2, 0]
   *   ]
   * };
   *
   * // As options we currently only set a static size of 300x200 px
   * const options = {
   *   width: '300px',
   *   height: '200px'
   * };
   *
   * // In the global name space Chartist we call the Line function to initialize a line chart. As a first parameter we pass in a selector where we would like to get our chart created. Second parameter is the actual data object and as a third parameter we pass in our options
   * new LineChart('.ct-chart', data, options);
   * ```
   *
   * @example
   * ```ts
   * // Use specific interpolation function with configuration from the Chartist.Interpolation module
   *
   * const chart = new LineChart('.ct-chart', {
   *   labels: [1, 2, 3, 4, 5],
   *   series: [
   *     [1, 1, 8, 1, 7]
   *   ]
   * }, {
   *   lineSmooth: Chartist.Interpolation.cardinal({
   *     tension: 0.2
   *   })
   * });
   * ```
   *
   * @example
   * ```ts
   * // Create a line chart with responsive options
   *
   * const data = {
   *   // A labels array that can contain any sort of values
   *   labels: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
   *   // Our series array that contains series objects or in this case series data arrays
   *   series: [
   *     [5, 2, 4, 2, 0]
   *   ]
   * };
   *
   * // In addition to the regular options we specify responsive option overrides that will override the default configutation based on the matching media queries.
   * const responsiveOptions = [
   *   ['screen and (min-width: 641px) and (max-width: 1024px)', {
   *     showPoint: false,
   *     axisX: {
   *       labelInterpolationFnc: function(value) {
   *         // Will return Mon, Tue, Wed etc. on medium screens
   *         return value.slice(0, 3);
   *       }
   *     }
   *   }],
   *   ['screen and (max-width: 640px)', {
   *     showLine: false,
   *     axisX: {
   *       labelInterpolationFnc: function(value) {
   *         // Will return M, T, W etc. on small screens
   *         return value[0];
   *       }
   *     }
   *   }]
   * ];
   *
   * new LineChart('.ct-chart', data, null, responsiveOptions);
   * ```
   */constructor(e,t,s,i){super(e,t,oe,m({},oe,s),i);this.data=t}}function le(e){return v(e,(function(){for(var e=arguments.length,t=new Array(e),s=0;s<e;s++)t[s]=arguments[s];return Array.from(t).reduce(((e,t)=>({x:e.x+(x(t,"x")?t.x:0),y:e.y+(x(t,"y")?t.y:0)})),{x:0,y:0})}))}const ce={axisX:{offset:30,position:"end",labelOffset:{x:0,y:0},showLabel:true,showGrid:true,labelInterpolationFnc:f,scaleMinSpace:30,onlyInteger:false},axisY:{offset:40,position:"start",labelOffset:{x:0,y:0},showLabel:true,showGrid:true,labelInterpolationFnc:f,scaleMinSpace:20,onlyInteger:false},width:void 0,height:void 0,high:void 0,low:void 0,referenceValue:0,chartPadding:{top:15,right:15,bottom:5,left:10},seriesBarDistance:15,stackBars:false,stackMode:"accumulate",horizontalBars:false,distributeSeries:false,reverseData:false,showGridBackground:false,classNames:{chart:"ct-chart-bar",horizontalBars:"ct-horizontal-bars",label:"ct-label",labelGroup:"ct-labels",series:"ct-series",bar:"ct-bar",grid:"ct-grid",gridGroup:"ct-grids",gridBackground:"ct-grid-background",vertical:"ct-vertical",horizontal:"ct-horizontal",start:"ct-start",end:"ct-end"}};class BarChart extends BaseChart{createChart(e){const{data:t}=this;const s=B(t,e.reverseData,e.horizontalBars?"x":"y",true);const i=G(this.container,e.width,e.height,e.classNames.chart+(e.horizontalBars?" "+e.classNames.horizontalBars:""),e.viewBox);const n=e.stackBars&&e.stackMode!==true&&s.series.length?O([le(s.series)],e,e.horizontalBars?"x":"y"):O(s.series,e,e.horizontalBars?"x":"y");this.svg=i;const a=i.elem("g").addClass(e.classNames.gridGroup);const o=i.elem("g");const l=i.elem("g").addClass(e.classNames.labelGroup);typeof e.high==="number"&&(n.high=e.high);typeof e.low==="number"&&(n.low=e.low);const c=U(i,e);let h;const u=e.distributeSeries&&e.stackBars?s.labels.slice(0,1):s.labels;let d;let m;let f;if(e.horizontalBars){h=m=e.axisX.type===void 0?new AutoScaleAxis(re.x,s.series,c,{...e.axisX,highLow:n,referenceValue:0}):new e.axisX.type(re.x,s.series,c,{...e.axisX,highLow:n,referenceValue:0});d=f=e.axisY.type===void 0?new StepAxis(re.y,s.series,c,{ticks:u}):new e.axisY.type(re.y,s.series,c,e.axisY)}else{d=m=e.axisX.type===void 0?new StepAxis(re.x,s.series,c,{ticks:u}):new e.axisX.type(re.x,s.series,c,e.axisX);h=f=e.axisY.type===void 0?new AutoScaleAxis(re.y,s.series,c,{...e.axisY,highLow:n,referenceValue:0}):new e.axisY.type(re.y,s.series,c,{...e.axisY,highLow:n,referenceValue:0})}const p=e.horizontalBars?c.x1+h.projectValue(0):c.y1-h.projectValue(0);const g=e.stackMode==="accumulate";const v=e.stackMode==="accumulate-relative";const w=[];const b=[];let E=w;d.createGridAndLabels(a,l,e,this.eventEmitter);h.createGridAndLabels(a,l,e,this.eventEmitter);e.showGridBackground&&T(a,c,e.classNames.gridBackground,this.eventEmitter);A(t.series,((i,n)=>{const a=n-(t.series.length-1)/2;let l;l=e.distributeSeries&&!e.stackBars?d.axisLength/s.series.length/2:e.distributeSeries&&e.stackBars?d.axisLength/2:d.axisLength/s.series[n].length/2;const u=o.elem("g");const A=x(i,"name")&&i.name;const C=x(i,"className")&&i.className;const M=x(i,"meta")?i.meta:void 0;A&&u.attr({"ct:series-name":A});M&&u.attr({"ct:meta":X(M)});u.addClass([e.classNames.series,C||"".concat(e.classNames.series,"-").concat(r(n))].join(" "));s.series[n].forEach(((t,r)=>{const o=x(t,"x")&&t.x;const A=x(t,"y")&&t.y;let C;C=e.distributeSeries&&!e.stackBars?n:e.distributeSeries&&e.stackBars?0:r;let M;M=e.horizontalBars?{x:c.x1+h.projectValue(o||0,r,s.series[n]),y:c.y1-d.projectValue(A||0,C,s.series[n])}:{x:c.x1+d.projectValue(o||0,C,s.series[n]),y:c.y1-h.projectValue(A||0,r,s.series[n])};if(d instanceof StepAxis){d.stretch||(M[d.units.pos]+=l*(e.horizontalBars?-1:1));M[d.units.pos]+=e.stackBars||e.distributeSeries?0:a*e.seriesBarDistance*(e.horizontalBars?-1:1)}v&&(E=A>=0||o>=0?w:b);const N=E[r]||p;E[r]=N-(p-M[d.counterUnits.pos]);if(t===void 0)return;const L={["".concat(d.units.pos,"1")]:M[d.units.pos],["".concat(d.units.pos,"2")]:M[d.units.pos]};if(e.stackBars&&(g||v||!e.stackMode)){L["".concat(d.counterUnits.pos,"1")]=N;L["".concat(d.counterUnits.pos,"2")]=E[r]}else{L["".concat(d.counterUnits.pos,"1")]=p;L["".concat(d.counterUnits.pos,"2")]=M[d.counterUnits.pos]}L.x1=Math.min(Math.max(L.x1,c.x1),c.x2);L.x2=Math.min(Math.max(L.x2,c.x1),c.x2);L.y1=Math.min(Math.max(L.y1,c.y2),c.y1);L.y2=Math.min(Math.max(L.y2,c.y2),c.y1);const O=S(i,r);const B=u.elem("line",L,e.classNames.bar).attr({"ct:value":[o,A].filter(y).join(","),"ct:meta":X(O)});this.eventEmitter.emit("draw",{type:"bar",value:t,index:r,meta:O,series:i,seriesIndex:n,axisX:m,axisY:f,chartRect:c,group:u,element:B,...L})}))}),e.reverseData);this.eventEmitter.emit("created",{chartRect:c,axisX:m,axisY:f,svg:i,options:e})}
/**
   * This method creates a new bar chart and returns API object that you can use for later changes.
   * @param query A selector query string or directly a DOM element
   * @param data The data object that needs to consist of a labels and a series array
   * @param options The options object with options that override the default options. Check the examples for a detailed list.
   * @param responsiveOptions Specify an array of responsive option arrays which are a media query and options object pair => [[mediaQueryString, optionsObject],[more...]]
   * @return An object which exposes the API for the created chart
   *
   * @example
   * ```ts
   * // Create a simple bar chart
   * const data = {
   *   labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
   *   series: [
   *     [5, 2, 4, 2, 0]
   *   ]
   * };
   *
   * // In the global name space Chartist we call the Bar function to initialize a bar chart. As a first parameter we pass in a selector where we would like to get our chart created and as a second parameter we pass our data object.
   * new BarChart('.ct-chart', data);
   * ```
   *
   * @example
   * ```ts
   * // This example creates a bipolar grouped bar chart where the boundaries are limitted to -10 and 10
   * new BarChart('.ct-chart', {
   *   labels: [1, 2, 3, 4, 5, 6, 7],
   *   series: [
   *     [1, 3, 2, -5, -3, 1, -6],
   *     [-5, -2, -4, -1, 2, -3, 1]
   *   ]
   * }, {
   *   seriesBarDistance: 12,
   *   low: -10,
   *   high: 10
   * });
   * ```
   */constructor(e,t,s,i){super(e,t,ce,m({},ce,s),i);this.data=t}}const he={width:void 0,height:void 0,chartPadding:5,classNames:{chartPie:"ct-chart-pie",chartDonut:"ct-chart-donut",series:"ct-series",slicePie:"ct-slice-pie",sliceDonut:"ct-slice-donut",label:"ct-label"},startAngle:0,total:void 0,donut:false,donutWidth:60,showLabel:true,labelOffset:0,labelPosition:"inside",labelInterpolationFnc:f,labelDirection:"neutral",ignoreEmptyValues:false,preventOverlappingLabelOffset:0};function ue(e,t,s){const i=t.x>e.x;return i&&s==="explode"||!i&&s==="implode"?"start":i&&s==="implode"||!i&&s==="explode"?"end":"middle"}class PieChart extends BaseChart{
/**
   * Check if a label has overlapping text then move it the number of pixels up and left based on textSize.
   * @param labelPos - Label position that chartist will be checking does not overlap with the list of LabelPositions.
   * @param existingLabelPos - Label position that has already been placed that chartist will check against.
   * @param textOffset - this is configured with preventOverlappingLabelOffset option.
   * @param length - How many characters long the label is.
   */
moveLabel(e,t,s,i){if(e.y>t.y-s&&e.y<t.y+s&&e.x>t.x-i*s&&e.x<t.x+i*s){e.y-=s;e.x-=s;this.moveLabel(e,t,s,i)}}
/**
   * Creates the pie chart
   *
   * @param options
   */createChart(e){const{data:t}=this;const s=B(t);const i=[];let a;const o=[];let l;let c=e.startAngle;const h=G(this.container,e.width,e.height,e.donut?e.classNames.chartDonut:e.classNames.chartPie,e.viewBox);this.svg=h;const d=U(h,e);let m=Math.min(d.width()/2,d.height()/2);const f=e.total||s.series.reduce(g,0);const p=n(e.donutWidth);p.unit==="%"&&(p.value*=m/100);m-=e.donut?p.value/2:0;l=e.labelPosition==="outside"||e.donut?m:e.labelPosition==="center"?0:m/2;e.labelOffset&&(l+=e.labelOffset);const v={x:d.x1+d.width()/2,y:d.y2+d.height()/2};const y=t.series.filter((e=>x(e,"value")?e.value!==0:e!==0)).length===1;t.series.forEach(((e,t)=>i[t]=h.elem("g")));e.showLabel&&(a=h.elem("g"));t.series.forEach(((n,h)=>{var g,b;if(s.series[h]===0&&e.ignoreEmptyValues)return;const E=x(n,"name")&&n.name;const A=x(n,"className")&&n.className;const S=x(n,"meta")?n.meta:void 0;E&&i[h].attr({"ct:series-name":E});i[h].addClass([(g=e.classNames)===null||g===void 0?void 0:g.series,A||"".concat((b=e.classNames)===null||b===void 0?void 0:b.series,"-").concat(r(h))].join(" "));let C=f>0?c+s.series[h]/f*360:0;const M=Math.max(0,c-(h===0||y?0:.2));C-M>=359.99&&(C=M+359.99);const N=u(v.x,v.y,m,M);const L=u(v.x,v.y,m,C);const O=new SvgPath(!e.donut).move(L.x,L.y).arc(m,m,0,Number(C-c>180),0,N.x,N.y);e.donut||O.line(v.x,v.y);const B=i[h].elem("path",{d:O.stringify()},e.donut?e.classNames.sliceDonut:e.classNames.slicePie);B.attr({"ct:value":s.series[h],"ct:meta":X(S)});e.donut&&B.attr({style:"stroke-width: "+p.value+"px"});this.eventEmitter.emit("draw",{type:"slice",value:s.series[h],totalDataSum:f,index:h,meta:S,series:n,group:i[h],element:B,path:O.clone(),center:v,radius:m,startAngle:c,endAngle:C,chartRect:d});if(e.showLabel){let i;i=t.series.length===1?{x:v.x,y:v.y}:u(v.x,v.y,l,c+(C-c)/2);let r;r=s.labels&&!w(s.labels[h])?s.labels[h]:s.series[h];const m=e.labelInterpolationFnc(r,h);if(m||m===0){if(e.preventOverlappingLabelOffset){const t=e.preventOverlappingLabelOffset;const n=String(s.labels[h]).length;o.forEach((e=>{this.moveLabel(i,e,t,n)}));o.push(i)}const t=a.elem("text",{dx:i.x,dy:i.y,"text-anchor":ue(v,i,e.labelDirection)},e.classNames.label).text(String(m));this.eventEmitter.emit("draw",{type:"label",index:h,group:a,element:t,text:""+m,chartRect:d,series:n,meta:S,...i})}}c=C}));this.eventEmitter.emit("created",{chartRect:d,svg:h,options:e})}
/**
   * This method creates a new pie chart and returns an object that can be used to redraw the chart.
   * @param query A selector query string or directly a DOM element
   * @param data The data object in the pie chart needs to have a series property with a one dimensional data array. The values will be normalized against each other and don't necessarily need to be in percentage. The series property can also be an array of value objects that contain a value property and a className property to override the CSS class name for the series group.
   * @param options The options object with options that override the default options. Check the examples for a detailed list.
   * @param responsiveOptions Specify an array of responsive option arrays which are a media query and options object pair => [[mediaQueryString, optionsObject],[more...]]
   *
   * @example
   * ```ts
   * // Simple pie chart example with four series
   * new PieChart('.ct-chart', {
   *   series: [10, 2, 4, 3]
   * });
   * ```
   *
   * @example
   * ```ts
   * // Drawing a donut chart
   * new PieChart('.ct-chart', {
   *   series: [10, 2, 4, 3]
   * }, {
   *   donut: true
   * });
   * ```
   *
   * @example
   * ```ts
   * // Using donut, startAngle and total to draw a gauge chart
   * new PieChart('.ct-chart', {
   *   series: [20, 10, 30, 40]
   * }, {
   *   donut: true,
   *   donutWidth: 20,
   *   startAngle: 270,
   *   total: 200
   * });
   * ```
   *
   * @example
   * ```ts
   * // Drawing a pie chart with padding and labels that are outside the pie
   * new PieChart('.ct-chart', {
   *   series: [20, 10, 30, 40]
   * }, {
   *   chartPadding: 30,
   *   labelOffset: 50,
   *   labelDirection: 'explode'
   * });
   * ```
   *
   * @example
   * ```ts
   * // Overriding the class names for individual series as well as a name and meta data.
   * // The name will be written as ct:series-name attribute and the meta data will be serialized and written
   * // to a ct:meta attribute.
   * new PieChart('.ct-chart', {
   *   series: [{
   *     value: 20,
   *     name: 'Series 1',
   *     className: 'my-custom-class-one',
   *     meta: 'Meta One'
   *   }, {
   *     value: 10,
   *     name: 'Series 2',
   *     className: 'my-custom-class-two',
   *     meta: 'Meta Two'
   *   }, {
   *     value: 70,
   *     name: 'Series 3',
   *     className: 'my-custom-class-three',
   *     meta: 'Meta Three'
   *   }]
   * });
   * ```
   */constructor(e,t,s,i){super(e,t,he,m({},he,s),i);this.data=t}}export{AutoScaleAxis,Axis,BarChart,BaseChart,a as EPSILON,EventEmitter,FixedScaleAxis,ie as Interpolation,LineChart,PieChart,StepAxis,Svg,SvgList,SvgPath,r as alphaNumerate,re as axisUnits,U as createChartRect,H as createGrid,T as createGridBackground,Q as createLabel,G as createSvg,Y as deserialize,ue as determineAnchorPosition,A as each,V as easings,i as ensureUnit,s as escapingMap,m as extend,d as getBounds,O as getHighLow,S as getMetaData,L as getMultiValue,b as getNumberOrUndefined,ae as getSeriesOption,E as isArrayOfArrays,M as isArrayOfSeries,C as isDataHoleValue,w as isFalseyButZero,N as isMultiValue,y as isNumeric,e as namespaces,f as noop,B as normalizeData,D as normalizePadding,F as optionsProvider,o as orderOfMagnitude,u as polarToCartesian,t as precision,l as projectLength,n as quantity,h as rho,c as roundWithPrecision,x as safeHasProperty,v as serialMap,X as serialize,z as splitIntoSegments,g as sum,p as times};

