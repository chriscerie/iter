"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[571],{3905:(e,t,n)=>{n.d(t,{Zo:()=>c,kt:()=>y});var r=n(67294);function a(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function o(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,r)}return n}function i(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?o(Object(n),!0).forEach((function(t){a(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):o(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function l(e,t){if(null==e)return{};var n,r,a=function(e,t){if(null==e)return{};var n,r,a={},o=Object.keys(e);for(r=0;r<o.length;r++)n=o[r],t.indexOf(n)>=0||(a[n]=e[n]);return a}(e,t);if(Object.getOwnPropertySymbols){var o=Object.getOwnPropertySymbols(e);for(r=0;r<o.length;r++)n=o[r],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(a[n]=e[n])}return a}var s=r.createContext({}),u=function(e){var t=r.useContext(s),n=t;return e&&(n="function"==typeof e?e(t):i(i({},t),e)),n},c=function(e){var t=u(e.components);return r.createElement(s.Provider,{value:t},e.children)},p="mdxType",m={inlineCode:"code",wrapper:function(e){var t=e.children;return r.createElement(r.Fragment,{},t)}},d=r.forwardRef((function(e,t){var n=e.components,a=e.mdxType,o=e.originalType,s=e.parentName,c=l(e,["components","mdxType","originalType","parentName"]),p=u(n),d=a,y=p["".concat(s,".").concat(d)]||p[d]||m[d]||o;return n?r.createElement(y,i(i({ref:t},c),{},{components:n})):r.createElement(y,i({ref:t},c))}));function y(e,t){var n=arguments,a=t&&t.mdxType;if("string"==typeof e||a){var o=n.length,i=new Array(o);i[0]=d;var l={};for(var s in t)hasOwnProperty.call(t,s)&&(l[s]=t[s]);l.originalType=e,l[p]="string"==typeof e?e:a,i[1]=l;for(var u=2;u<o;u++)i[u]=n[u];return r.createElement.apply(null,i)}return r.createElement.apply(null,n)}d.displayName="MDXCreateElement"},16500:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>s,contentTitle:()=>i,default:()=>m,frontMatter:()=>o,metadata:()=>l,toc:()=>u});var r=n(87462),a=(n(67294),n(3905));const o={sidebar_position:2},i="Lazy evaluation",l={unversionedId:"lazy",id:"lazy",title:"Lazy evaluation",description:"Iterators are lazy, meaning they don't do any processing work until you need them. This code won't run because map by itself doesn't do anything, because the would-be result is never used.",source:"@site/docs/lazy.md",sourceDirName:".",slug:"/lazy",permalink:"/iter/docs/lazy",draft:!1,editUrl:"https://github.com/chriscerie/iter/edit/main/docs/lazy.md",tags:[],version:"current",sidebarPosition:2,frontMatter:{sidebar_position:2},sidebar:"defaultSidebar",previous:{title:"Introduction",permalink:"/iter/docs/intro"}},s={},u=[],c={toc:u},p="wrapper";function m(e){let{components:t,...n}=e;return(0,a.kt)(p,(0,r.Z)({},c,n,{components:t,mdxType:"MDXLayout"}),(0,a.kt)("h1",{id:"lazy-evaluation"},"Lazy evaluation"),(0,a.kt)("p",null,"Iterators are lazy, meaning they don't do any processing work until you need them. This code won't run because ",(0,a.kt)("inlineCode",{parentName:"p"},"map")," by itself doesn't do anything, because the would-be result is never used."),(0,a.kt)("pre",null,(0,a.kt)("code",{parentName:"pre",className:"language-lua"},"    iter.array(t):map(function(value: number)\n        -- This never runs\n        return value * 2\n    end)\n")),(0,a.kt)("p",null,"Iterators only run when they are needed and consumed. There's several ways to consume iterators. One of the most common ways is to grab the resulting table with ",(0,a.kt)("inlineCode",{parentName:"p"},"collect"),"."),(0,a.kt)("pre",null,(0,a.kt)("code",{parentName:"pre",className:"language-lua"},"    iter.array(t)\n        :map(function(value: number)\n            -- Now this runs\n            return value * 2\n        end)\n        :collect()\n")),(0,a.kt)("p",null,"This mechanism enables ",(0,a.kt)("inlineCode",{parentName:"p"},"iter")," to perform aggressive optimizations when it can. Imagine you want to apply some expensive transformation function to an array, but you only want to get the first 40 elements. ",(0,a.kt)("inlineCode",{parentName:"p"},"iter")," will see that you don't need the entire array to be transformed, so it will stop at the first 40. If the original array is some extreme size, it's that many iterations that ",(0,a.kt)("inlineCode",{parentName:"p"},"iter")," avoids."),(0,a.kt)("pre",null,(0,a.kt)("code",{parentName:"pre",className:"language-lua"},"    iter.array(t)\n        :map(function(value: number)\n            -- Only runs 40 times even if array is much larger\n            return someExpensiveFn(value)\n        end)\n        :take(40)\n        :collect()\n")),(0,a.kt)("p",null,"While this short circuiting behavior can also be implemented in traditional loops (use a counter and break out of the loop after 40 iterations), it requires the consuming logic to be next to the transformation logic."),(0,a.kt)("p",null,"Imagine you own a table, want to apply some transformation to it, then pass it off to another part of the code to ultimately consume. Many times you don't have any information on how the table will eventually get used - the downstream consumer can read the entire table, just the first few elements, or even just check if a condition holds true (like if any elements is even). In these cases, traditional loops would require you to apply the transformation function for the entire table, no matter how much of the table the consumer needs."),(0,a.kt)("p",null,"Instead, with ",(0,a.kt)("inlineCode",{parentName:"p"},"iter")," we can queue transformations, but they won't take effect immediately. We can then pass the entire iterator to the consumer and ",(0,a.kt)("inlineCode",{parentName:"p"},"iter")," will make any optimizations as necessary when it ultimately gets consumed."))}m.isMDXComponent=!0}}]);