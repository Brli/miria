import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:miria/providers.dart';
import 'package:miria/router/app_router.dart';
import 'package:miria/view/login_page/centraing_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiKeyLogin extends ConsumerStatefulWidget {
  const ApiKeyLogin({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => APiKeyLoginState();
}

class APiKeyLoginState extends ConsumerState<ApiKeyLogin> {
  final serverController = TextEditingController();
  final apiKeyController = TextEditingController();

  Future<void> login() async {
    await ref
        .read(accountRepository)
        .loginAsToken(serverController.text, apiKeyController.text);

    if (!mounted) return;
    context.pushRoute(TimeLineRoute(
        currentTabSetting:
            ref.read(tabSettingsRepositoryProvider).tabSettings.first));
  }

  @override
  Widget build(BuildContext context) {
    return CenteringWidget(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
            },
            children: [
              TableRow(children: [
                const Text("サーバー"),
                TextField(
                  controller: serverController,
                  decoration:
                      const InputDecoration(prefixIcon: Icon(Icons.dns)),
                ),
              ]),
              TableRow(children: [
                Padding(padding: EdgeInsets.only(bottom: 10)),
                Container()
              ]),
              TableRow(children: [
                const Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Text("APIキー"),
                ),
                TextField(
                  controller: apiKeyController,
                  decoration: InputDecoration(prefixIcon: Icon(Icons.key)),
                )
              ]),
              // ],
              TableRow(children: [
                Container(),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: ElevatedButton(
                      onPressed: () {
                        login();
                      },
                      child: const Text("ログイン")),
                )
              ])
            ],
          ),
        ],
      ),
    );
  }
}