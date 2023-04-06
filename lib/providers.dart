import 'package:flutter_misskey_app/mfm_to_flutter_html/mfm_to_flutter_html.dart';
import 'package:flutter_misskey_app/repository/emoji_repository.dart';
import 'package:flutter_misskey_app/repository/global_time_line_repository.dart';
import 'package:flutter_misskey_app/repository/home_time_line_repository.dart';
import 'package:flutter_misskey_app/repository/local_time_line_repository.dart';
import 'package:flutter_misskey_app/repository/time_line_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mfm/mfm.dart';
import 'package:misskey_dart/misskey_dart.dart';

final misskeyProvider = Provider((ref) =>
    Misskey(token: "Ptk6oVyZg9JrLOJpRTSzfu6iofZ9Dz2O", host: "misskey.io"));

final localTimeLineProvider = ChangeNotifierProvider<TimeLineRepository>(
    (ref) => LocalTimeLineRepository(ref.read(misskeyProvider)));
final homeTimeLineProvider = ChangeNotifierProvider<TimeLineRepository>(
    (ref) => HomeTimeLineRepository(ref.read(misskeyProvider)));
final globalTimeLineProvider = ChangeNotifierProvider<TimeLineRepository>(
    (ref) => GlobalTimeLineRepository(ref.read(misskeyProvider)));


final emojiRepositoryProvider =
    Provider((ref) => EmojiRepositoryImpl(misskey: ref.read(misskeyProvider)));
final mfmToFlutterHtmlProvider = Provider((ref) => MfmToFlutterHtml(
    ref.read(emojiRepositoryProvider), ref.read(mfmParserProvider)));
final mfmParserProvider = Provider<MfmParser>((ref) => const MfmParser());
