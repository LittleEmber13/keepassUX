import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keepassux/ui/bloc/entries/keepass_bloc.dart';
import 'package:keepassux/ui/bloc/entries/keepass_states.dart';
import 'package:keepassux/ui/pages/entries_page.dart';

import '../bloc/entries/keepass_events.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KeePassBloc, KeePassState>(
      listener: (context, state) {
        if (state is KeePassLoaded) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EntriesPage()),
          );
        }
      },
      builder: (context, state) {
        if (state is KeePassLoading) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else {
          return _page();
        }
      },
    );
  }

  Widget _page() {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: Offset(1, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        String password = 'test123';
                        ByteData data = await rootBundle.load(
                          'assets/test.kdbx',
                        );
                        Uint8List bytes = data.buffer.asUint8List();
                        context.read<KeePassBloc>().add(
                          LoadDatabase(bytes: bytes, password: password),
                        );
                      },
                      child: Text("Select database"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
