import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:enough_ascii_art/enough_ascii_art.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/process_run.dart';

class CmdVM extends ChangeNotifier {
  final controller = ScrollController();
  String dir;
  bool isRunning = false;
  List<String> items = [];
  var context;
  StreamController msg = StreamController<List<int>>.broadcast();
  get root {
    var t = mHome.split('/');
    t.removeLast();
    return t.join('/');
  }

  final TextEditingController tec = new TextEditingController();
  final user = StreamController<List<int>>();

  @override
  void dispose() {
    user.close();
    msg.close();
    super.dispose();
  }

  String get mHome {
    String home = "";
    Map<String, String> envVars = Platform.environment;
    if (Platform.isMacOS) {
      home = envVars['HOME'];
    } else if (Platform.isLinux) {
      home = envVars['HOME'];
    } else if (Platform.isWindows) {
      home = envVars['UserProfile'];
    }
    return home;
  }

  init() async {
    dir = mHome;
    notifyListeners();
    user.stream.listen(
      (user) => items
          .add(utf8.decode(Uint8List.fromList(user), allowMalformed: true)),
    );
  }

  Future<ByteData> loadFontFromAssets(v) async {
    return (await rootBundle.load('fonts/$v.flf'));
  }

  Future<File> writeToFile(ByteData data) async {
    final buffer = data.buffer;
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var filePath =
        tempPath + '/x.flf'; // file_01.tmp is dump file, can be anything
    return new File(filePath).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  loadFont() async {
    try {
      var m = await writeToFile(await loadFontFromAssets('standard'));
      var v = await m.readAsLines();

      var parser = Parser();
      var font = parser.parseFontDefinition(v);
      var figure = renderFiglet('ZTERMINAL', font);

      items.add(figure);
      items.add('Version 1.0');
      items.add('\n');
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  cmd(String s) async {
    if (isRunning) {
      print('isRunning');
      msg.add(tec.text.runes.toList());
      
      notifyListeners();
      return;
    }
    if (s.toLowerCase() == 'exit') {
      Phoenix.rebirth(context);
      user.close();
      msg.close();
      return;
    } else if (s.toLowerCase() == 'help') {
      loadFont();
      tec.clear();
      return;
    }

    if (Platform.isWindows) {
      if (s.toLowerCase() == 'cls') {
        items = [];
        notifyListeners();

        tec.clear();
      }
      return;
    } else {
      if (s.toLowerCase() == 'clear') {
        items = [];
        notifyListeners();

        tec.clear();
        return;
      }
    }
    try {
      isRunning = true;
      notifyListeners();
      String ex;

      var spl = s.split(' ');
      ex = spl.first;

      spl.removeAt(0);
      List<String> h = [];

      spl.forEach((f) {
        if (f.isNotEmpty) {
          h.add(f);
          notifyListeners();
        }
      });

      tec.clear();
      var t = await run(ex, h,
          stdout: user.sink,
          stderr: user.sink,
          stdin: msg.stream,
          stdoutEncoding: Encoding.getByName('US-ASCII'),
          verbose: true,
          commandVerbose: true,
          workingDirectory: dir);
      isRunning = false;
      notifyListeners();

      print(t.stdout);
      if (t.stderr.toString().isEmpty &&
          !t.stdout.toString().contains('ProcessException:')) {
        if (ex == 'cd' && !s.contains('..')) {
          dir = dir + "/" + spl.join(' ');
        } else if (ex == 'cd' && s.contains('..')) {
          if (dir != null) {
            var m = dir.split("/");
            m.removeLast();
            if (root.toLowerCase() != m.join('/').toLowerCase())
              dir = m.join("/");
          }
        } else if (ex == 'cd') {
          dir = dir + "/" + spl.join(' ');
        }
        notifyListeners();

        controller.animateTo(
          controller.position.maxScrollExtent * 2,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      items.add(e.toString());
      isRunning = true;
      isRunning = true;
      notifyListeners();
      print(e.toString());
    }
  }
}
