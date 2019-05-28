# kex-assetpack [![License: Zlib](https://img.shields.io/badge/License-Zlib-green.svg)](https://opensource.org/licenses/Zlib) [![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

A small utility library for dealing with assets.

## usage

```haxe
using kex.AssetPackExtension;

final preload = [
	ImageAsset('loading', 'preloader/loading-screen.png'),
	ImageAsset('progress', 'preloader/progess-bar.png'),
	FontAsset('sys', 'inconsolata-bold.ttf'),
];

kha.Assets.loadAssetPack(preload, r -> {
	if (r.failures.length > 0) {
		trace('failed to preload assets');
		return;
	}

	final bg  = r.assets.images.get('loading');
	final progress = r.assets.images.get('progress');
	final fnt = r.assets.fonts.get('sys');
	...
});
```
