import "dart:io";

import "package:device_info_plus/device_info_plus.dart";
import "package:dio/dio.dart";
import "package:flutter/foundation.dart";
import "package:image/image.dart";
import "package:image_gallery_saver/image_gallery_saver.dart";
import "package:miria/providers.dart";
import "package:misskey_dart/misskey_dart.dart" hide Permission;
import "package:permission_handler/permission_handler.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

part "download_file_notifier.g.dart";

enum DownloadFileResult { succeeded, failed, permissionDenied }

@Riverpod(keepAlive: true)
class DownloadFileNotifier extends _$DownloadFileNotifier {
  @override
  void build() {
    return;
  }

  Future<DownloadFileResult> downloadFile(DriveFile driveFile) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        final permissionStatus = await Permission.storage.status;
        if (permissionStatus.isDenied) {
          final p = await Permission.storage.request();
          if (!p.isGranted) {
            return DownloadFileResult.permissionDenied;
          }
        }
      } else {
        final permissionStatus = await Permission.photos.status;
        if (permissionStatus.isDenied) {
          final p = await Permission.photos.request();
          if (!p.isGranted) {
            return DownloadFileResult.permissionDenied;
          }
        }
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final permissionStatus = await Permission.photosAddOnly.status;
      if (!permissionStatus.isGranted) {
        return DownloadFileResult.permissionDenied;
      }
    }

    final tempDir = ref.read(fileSystemProvider).systemTempDirectory;
    var savePath = "${tempDir.path}/${driveFile.name}";

    await ref.read(dioProvider).download(
          driveFile.url,
          savePath,
          options: Options(
            responseType: ResponseType.bytes,
          ),
        );

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final imageBytes = await File(savePath).readAsBytes();
      final d = findDecoderForData(imageBytes);
      if (d == null) return DownloadFileResult.failed;

      if (d.format == ImageFormat.webp) {
        final decoder = WebPDecoder();
        final info = decoder.startDecode(imageBytes);
        final image = decoder.decode(imageBytes);
        if (info == null || image == null) return DownloadFileResult.failed;

        switch (info.format) {
          case WebPFormat.animated:
            savePath = "$savePath.gif";
            await File(savePath).writeAsBytes(encodeGif(image));

          case WebPFormat.lossy:
            savePath = "$savePath.jpg";
            await File(savePath).writeAsBytes(encodeJpg(image));

          case WebPFormat.lossless:
          case WebPFormat.undefined:
            savePath = "$savePath.png";
            await File(savePath).writeAsBytes(encodePng(image));

          default:
            return DownloadFileResult.failed;
        }
      }
    }
    await ImageGallerySaver.saveFile(
      savePath,
      name: driveFile.name,
    );
    return DownloadFileResult.succeeded;
  }
}
