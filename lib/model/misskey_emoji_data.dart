import 'package:miria/repository/emoji_repository.dart';
import 'package:misskey_dart/misskey_dart.dart';
import 'package:collection/collection.dart';

sealed class MisskeyEmojiData {
  final String baseName;
  const MisskeyEmojiData(this.baseName);

  factory MisskeyEmojiData.fromEmojiName({
    required String emojiName,
    Map<String, String>? emojiInfo,
    EmojiRepository? repository,
  }) {
    // Unicodeの絵文字
    if (!emojiName.startsWith(":")) {
      return UnicodeEmojiData(char: emojiName);
    }

    final customEmojiRegExp = RegExp(r":(.+?)@(.+?):");
    final hostIncludedRegExp = RegExp(r":(.+?):");

    // よそのサーバー
    if (emojiInfo != null && emojiInfo.isNotEmpty) {
      final baseName =
          customEmojiRegExp.firstMatch(emojiName)?.group(1) ?? emojiName;
      final hostIncludedBaseName =
          hostIncludedRegExp.firstMatch(emojiName)?.group(1) ?? emojiName;

      final found = emojiInfo[hostIncludedBaseName];
      if (found != null) {
        return CustomEmojiData(
          baseName: baseName,
          hostedName: emojiName,
          url: Uri.parse(found),
          isCurrentServer: false,
        );
      }
    }

    // 自分のサーバー :ai@.:
    if (customEmojiRegExp.hasMatch(emojiName)) {
      assert(repository != null);
      final EmojiRepositoryData? found = repository!.emoji?.firstWhereOrNull(
          (e) =>
              e.emoji.baseName ==
              (customEmojiRegExp.firstMatch(emojiName)?.group(1) ?? emojiName));
      if (found != null) {
        return found.emoji;
      } else {
        return NotEmojiData(name: emojiName);
      }
    }

    // 自分のサーバー　:ai:
    final customEmojiRegExp2 = RegExp(r"^:(.+?):$");
    if (customEmojiRegExp2.hasMatch(emojiName)) {
      assert(repository != null);
      final EmojiRepositoryData? found = repository!.emoji?.firstWhereOrNull(
          (e) =>
              e.emoji.baseName ==
              (customEmojiRegExp2.firstMatch(emojiName)?.group(1) ??
                  emojiName));

      if (found != null) {
        return found.emoji;
      } else {
        return NotEmojiData(name: emojiName);
      }
    }

    return NotEmojiData(name: emojiName);
  }
}

/// 絵文字に見せかけた単なるテキスト
class NotEmojiData extends MisskeyEmojiData {
  const NotEmojiData({required this.name}) : super(name);
  final String name;
}

/// カスタム絵文字
class CustomEmojiData extends MisskeyEmojiData {
  const CustomEmojiData({
    required String baseName,
    required this.hostedName,
    required this.url,
    required this.isCurrentServer,
  }) : super(baseName);

  final String hostedName;
  final Uri url;
  final bool isCurrentServer;
}

/// Unicode絵文字
class UnicodeEmojiData extends MisskeyEmojiData {
  const UnicodeEmojiData({
    required this.char,
  }) : super(char);

  final String char;
}