package kex;

import kha.AssetError;
import kha.Assets;
import kha.Blob;
import kha.Image;
import kha.Font;
import kha.Sound;
import kha.Video;

enum Asset {
	BlobAsset( url: String );
	ImageAsset( url: String, ?readable: Bool );
	FontAsset( url: String );
	SoundAsset( url: String, ?uncompress: Bool );
	VideoAsset( url: String );
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
	done: AssetPackLoadingResult -> Void,
}

class AssetPackExtension {
	public static function loadAssetPack( a: Class<Assets>, pack: AssetPack, done: AssetPackLoadingResult -> Void ) {
		var status = {
			loaded: 0,
			total: pack.length,
			done: done,
		}

		var result: AssetPackLoadingResult = {
			assets: new LoadedAssets(),
			failures: [],
		}

		for (a in pack) {
			switch a {
				case BlobAsset(url):
					Assets.loadBlobFromPath(url, blobLoaded.bind(_, url, status, result), assetFailed.bind(_, status, result));
					// public static function loadBlob(name: String, done: Blob -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
					// public static function loadBlobFromPath(path: String, done: Blob -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
				case ImageAsset(url, readable):
					Assets.loadImageFromPath(url, readable, imageLoaded.bind(_, url, status, result), assetFailed.bind(_, status, result));
					// public static function loadImage(name: String, done: Image -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
					// public static function loadImageFromPath(path: String, readable: Bool, done: Image -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
				case FontAsset(url):
					Assets.loadFontFromPath(url, fontLoaded.bind(_, url, status, result), assetFailed.bind(_, status, result));
					// public static function loadFont(name: String, done: Font -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
					// public static function loadFontFromPath(path: String, done: Font -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
				case SoundAsset(url, uncompress):
					Assets.loadSoundFromPath(url, soundLoaded.bind(_, uncompress, url, status, result), assetFailed.bind(_, status, result));
					// public static function loadSound(name: String, done: Sound -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
					// public static function loadSoundFromPath(path: String, done: Sound -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
				case VideoAsset(url):
					Assets.loadVideoFromPath(url, videoLoaded.bind(_, url, status, result), assetFailed.bind(_, status, result));
					// public static function loadVideo(name: String, done: Video -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
					// public static function loadVideoFromPath(path: String, done: Video -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
			}
		}
	}

	static function blobLoaded( blob: Blob, id: String, status: Status, result: AssetPackLoadingResult ) {
		result.assets.blobs.set(id, blob);
		updateStatus(1, status, result);
	}

	static function imageLoaded( img: Image, id: String, status: Status, result: AssetPackLoadingResult ) {
		result.assets.images.set(id, img);
		updateStatus(1, status, result);
	}

	static function fontLoaded( fnt: Font, id: String, status: Status, result: AssetPackLoadingResult ) {
		result.assets.fonts.set(id, fnt);
		updateStatus(1, status, result);
	}

	// TODO (DK) handle uncompress
	static function soundLoaded( snd: Sound, uncompress, id: String, status: Status, result: AssetPackLoadingResult ) {
		if (uncompress) {
			trace('TODO (DK) uncompress sound');
		}

		result.assets.sounds.set(id, snd);
		updateStatus(1, status, result);
	}

	static function videoLoaded( vid: Video, id: String, status: Status, result: AssetPackLoadingResult ) {
		result.assets.videos.set(id, vid);
		updateStatus(1, status, result);
	}

	static function updateStatus( add: Int, status: Status, result: AssetPackLoadingResult ) {
		status.loaded += add;
		check(status, result);
	}

	static function assetFailed( err, status: Status, result: AssetPackLoadingResult ) {
		result.failures.push(err);
		check(status, result);
	}

	static function check( status: Status, result: AssetPackLoadingResult ) {
		if (status.loaded + result.failures.length == status.total) {
			status.done(result);
		}
	}
}
