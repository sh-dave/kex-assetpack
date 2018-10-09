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

private typedef Status = {
	loaded: Int,
	failures: Array<AssetError>,
	total: Int,
	done: LoadedAssets -> Void,
	loadedAssets: LoadedAssets,
}

class AssetPackExtension {
	public static function loadAssetPack( a: Class<Assets>, pack: AssetPack, done: LoadedAssets -> Void ) {
		var status = {
			loaded: 0,
			failures: [],
			total: pack.length,
			done: done,
			loadedAssets: new LoadedAssets(),
		}

		for (a in pack) {
			switch a {
				case BlobAsset(url):
					Assets.loadBlobFromPath(url, blobLoaded.bind(_, url, status), assetFailed.bind(_, status));
					// public static function loadBlob(name: String, done: Blob -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
					// public static function loadBlobFromPath(path: String, done: Blob -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
				case ImageAsset(url, readable):
					Assets.loadImageFromPath(url, readable, imageLoaded.bind(_, url, status), assetFailed.bind(_, status));
					// public static function loadImage(name: String, done: Image -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
					// public static function loadImageFromPath(path: String, readable: Bool, done: Image -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
				case FontAsset(url):
					Assets.loadFontFromPath(url, fontLoaded.bind(_, url, status), assetFailed.bind(_, status));
					// public static function loadFont(name: String, done: Font -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
					// public static function loadFontFromPath(path: String, done: Font -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
				case SoundAsset(url, uncompress):
					Assets.loadSoundFromPath(url, soundLoaded.bind(_, uncompress, url, status), assetFailed.bind(_, status));
					// public static function loadSound(name: String, done: Sound -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
					// public static function loadSoundFromPath(path: String, done: Sound -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
				case VideoAsset(url):
					Assets.loadVideoFromPath(url, videoLoaded.bind(_, url, status), assetFailed.bind(_, status));
					// public static function loadVideo(name: String, done: Video -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
					// public static function loadVideoFromPath(path: String, done: Video -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
			}
		}
	}

	static function blobLoaded( blob: Blob, id: String, status: Status ) {
		status.loadedAssets.blobs.set(id, blob);
		updateStatus(1, status);
	}

	static function imageLoaded( img: Image, id: String, status: Status ) {
		status.loadedAssets.images.set(id, img);
		updateStatus(1, status);
	}

	static function fontLoaded( fnt: Font, id: String, status: Status ) {
		status.loadedAssets.fonts.set(id, fnt);
		updateStatus(1, status);
	}

	// TODO (DK) handle uncompress
	static function soundLoaded( snd: Sound, uncompress, id: String, status: Status ) {
		if (uncompress) {
			trace('TODO (DK) uncompress sound');
		}

		status.loadedAssets.sounds.set(id, snd);
		updateStatus(1, status);
	}

	static function videoLoaded( vid: Video, id: String, status: Status ) {
		status.loadedAssets.videos.set(id, vid);
		updateStatus(1, status);
	}

	static function updateStatus( add: Int, status: Status ) {
		status.loaded += add;
		check(status);
	}

	static function assetFailed( err, status: Status ) {
		status.failures.push(err);
		check(status);
	}

	static function check( status: Status ) {
		if (status.loaded + status.failures.length == status.total) {
			status.done(status.loadedAssets);
		}
	}
}
