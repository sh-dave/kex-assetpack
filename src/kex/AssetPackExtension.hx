package kex;

import kha.AssetError;
import kha.Assets;
import kha.Blob;
import kha.Image;
import kha.Font;
import kha.Sound;
import kha.Video;

enum Asset {
	BlobAsset( id: String, url: String, ?required: Bool );
	ImageAsset( id: String, url: String, ?readable: Bool, ?required: Bool );
	FontAsset( id: String, url: String, ?required: Bool );
	SoundAsset( id: String, url: String, ?uncompress: Bool, ?required: Bool );
	VideoAsset( id: String, url: String, ?required: Bool );
}

typedef AssetPack = Array<Asset>;

class LoadedAssets {
	public var blobs(default, null) = new Map<String, Blob>();
	public var images(default, null) = new Map<String, Image>();
	public var fonts(default, null) = new Map<String, Font>();
	public var sounds(default, null) = new Map<String, Sound>();
	public var videos(default, null) = new Map<String, Video>();

	public function new() {}
}

@:structInit class AssetPackLoadingResult {
	public var assets: LoadedAssets;
	public var failures: Array<AssetError>;
}

private typedef Status = {
	loaded: Int,
	total: Int,
	missing: Int,
	done: AssetPackLoadingResult -> Void,
}

class AssetPackExtension {
	public static function loadAssetPack( a: Class<Assets>, pack: AssetPack, done: AssetPackLoadingResult -> Void ) {
		var status = {
			loaded: 0,
			missing: 0,
			total: pack.length,
			done: done,
		}

		var result: AssetPackLoadingResult = {
			assets: new LoadedAssets(),
			failures: [],
		}

		for (a in pack) {
			switch a {
				case BlobAsset(id, url, required):
					Assets.loadBlobFromPath(url, blobLoaded.bind(_, id, url, status, result), assetFailed.bind(_, status, result, required));
				case ImageAsset(id, url, readable, required):
					Assets.loadImageFromPath(url, readable, imageLoaded.bind(_, id, url, status, result), assetFailed.bind(_, status, result, required));
				case FontAsset(id, url, required):
					Assets.loadFontFromPath(url, fontLoaded.bind(_, id, url, status, result), assetFailed.bind(_, status, result, required));
				case SoundAsset(id, url, uncompress, required):
					Assets.loadSoundFromPath(url, soundLoaded.bind(_, uncompress, id, url, status, result), assetFailed.bind(_, status, result, required));
				case VideoAsset(id, url, required):
					Assets.loadVideoFromPath(url, videoLoaded.bind(_, id, url, status, result), assetFailed.bind(_, status, result, required));
			}
		}
	}

	static function blobLoaded( blob: Blob, id: String, url: String, status: Status, result: AssetPackLoadingResult ) {
		result.assets.blobs.set(id, blob);
		updateStatus(1, status, result);
	}

	static function imageLoaded( img: Image, id: String, url: String, status: Status, result: AssetPackLoadingResult ) {
		result.assets.images.set(id, img);
		updateStatus(1, status, result);
	}

	static function fontLoaded( fnt: Font, id: String, url: String, status: Status, result: AssetPackLoadingResult ) {
		result.assets.fonts.set(id, fnt);
		updateStatus(1, status, result);
	}

	// TODO (DK) handle uncompress
	static function soundLoaded( snd: Sound, uncompress, url: String, id: String, status: Status, result: AssetPackLoadingResult ) {
		if (uncompress) {
			trace('TODO (DK) uncompress sound');
		}

		result.assets.sounds.set(id, snd);
		updateStatus(1, status, result);
	}

	static function videoLoaded( vid: Video, url: String, id: String, status: Status, result: AssetPackLoadingResult ) {
		result.assets.videos.set(id, vid);
		updateStatus(1, status, result);
	}

	static function updateStatus( add: Int, status: Status, result: AssetPackLoadingResult ) {
		status.loaded += add;
		check(status, result);
	}

	static function assetFailed( err, status: Status, result: AssetPackLoadingResult, ?required: Bool ) {
		if (required) {
			result.failures.push(err);
		} else {
			status.missing += 1;
		}

		check(status, result);
	}

	static function check( status: Status, result: AssetPackLoadingResult ) {
		if (status.loaded + result.failures.length + status.missing == status.total) {
			status.done(result);
		}
	}
}
