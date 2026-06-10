import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keepassux/ui/bloc/entries/keepass_bloc.dart';
import 'package:keepassux/ui/pages/start_page.dart';
import 'package:keepassux/ui/theme/theme.dart';
import 'package:zxcvbnm/messages.dart';
import 'package:zxcvbnm_flutter/zxcvbnm_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await initializeZxcvbnmMessages('es');
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('es')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => KeePassBloc(),
      child: MaterialApp(
        title: 'KeepassUX',
        localizationsDelegates: [
          ...context.localizationDelegates,
          ZxcvbnmLocalizations.delegate,
        ],
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: themeData,
        home: StartPage(),
      ),
    );
  }
}
