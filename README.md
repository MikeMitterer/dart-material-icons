# Dart Material SVG Icons
### Optimized for Dart + SASS###

[Material Design Icons][materialicons] are the official open-source icons featured in the Google Material Design specification.
This project provides this icon-set for Dart.
 
##What's cool##
Googles original version comes "only" with black or white SVGs.  
**material_icons** allows you to **theme** your icons!!!  
Tested with Chrome, Safari, FF + IE.
IE - needs the no-svg class (see below)  

![Screenshot][screenshot]

##Usage##
* Clone the ["purple"][purple] example
* Open <a href="https://rawgit.com/MikeMitterer/dart-material-icons/master/lib/sass/index.html" target="_blank">[this]</a> page
  - Use Chrome or Safari for this!
* Click on icon that you want to include in your project
* Copy the **_material-icons.scss** section
* Paste it into your _material-icons.scss
```css
@import 'packages/material_icons/assets/action/svg/production/ic_favorite_24px';
.bg-ic_favorite_24px {
    @include svg-background("24");
    @include svg-fallback("action/svg/production/ic_favorite_24px.svg","action/2x_web/ic_favorite_black_24dp.png","action/2x_web/ic_favorite_white_24dp.png","action/2x_web/ic_favorite_grey600_24dp.png");
    background-image: svg-ic_favorite_24px($icon-color);
}
```
* Copy the **index.html** section
* Paste it into your index.html
```html
    <div class="bg-ic_favorite_24px svg-size-24 svg-bg"></div>
```
* In main.scss define your icon-color: `$icon-color : #9B30FF;`
* In web/styles: **sass main.scss main.css -r ../packages/material_icons/sassext/urlencode.rb**
* and: **autoprefixer main.css**

**Note**
You may ask what the hack???? does that mean:  
-r ../packages/material_icons/sassext/urlencode.rb  
You are adding a custom ruby-function to sass - here it is urlencode(...).  
The inline SVG get urlencoded and makes IE happy.  

That's it.    
Your page should look like <a href="https://rawgit.com/MikeMitterer/dart-material-icons/master/example/purple/web/index.html" target="_blank">[this]</a> page   

###Play with your index.html###

```html
<body class="no-svg fallback-white">
    <div class="bg-ic_favorite_24px svg-size-24 svg-bg"></div>
    <div class="bg-ic_account_balance_24px svg-size-24 svg-bg fallback-grey"></div>
    <div class="bg-ic_accessibility_48px svg-size-48 svg-bg"></div>
</body>
```
**no-svg** - turns off svg and uses png's instead  
**fallback-white** | **fallback-black** | **fallback-grey** - PNG color to use  
This option can also be specified per div (line 3).    

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

###License###

    Copyright 2015 Michael Mitterer (office@mikemitterer.at),
    IT-Consulting and Development Limited, Austrian Branch

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
    either express or implied. See the License for the specific language
    governing permissions and limitations under the License.
    
If this plugin is helpful for you - please [(Circle)](http://gplus.mikemitterer.at/) me  
or **star** this repo here on GitHub.
      
[tracker]: https://github.com/MikeMitterer/dart-material-icons/issues
[live]: https://rawgit.com/MikeMitterer/dart-material-icons/master/lib/sass/index.html
[materialicons]: https://github.com/google/material-design-icons
[purple]: https://github.com/MikeMitterer/dart-material-icons/tree/master/example/purple
[screenshot]: https://github.com/MikeMitterer/dart-material-icons/raw/master/lib/assets/screenshot.png?raw=true
