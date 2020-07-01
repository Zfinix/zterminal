import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zterminal/core/view_models/cmd_vm.dart';
import 'package:zterminal/utils/theme.dart';

final providerMain = ChangeNotifierProvider((_) => CmdVM());

class CMD extends StatefulHookWidget {
  CMD({Key key}) : super(key: key);

  @override
  _CMDState createState() => _CMDState();
}

class _CMDState extends State<CMD> {
  @override
  void initState() {
    providerMain.read(context).init();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var prov = useProvider(providerMain);
    prov.context = context;
    return Material(
      color: black,
      child: ListView(
        padding: EdgeInsets.all(20),
        controller: prov.controller,
        shrinkWrap: true,
        children: [
          if (prov.items.length > 0)
            SelectableText(
              (prov.items ?? [' ']).join('\n'),
              showCursor: true,
              enableInteractiveSelection: true,
              dragStartBehavior: DragStartBehavior.down,
              toolbarOptions: ToolbarOptions(),
              style: GoogleFonts.sourceCodePro(
                  fontSize: 13,
                  color: white.withOpacity(0.7),
                  fontWeight: FontWeight.w200,
                  height: 1.7),
            ),
          Row(
            children: [
              Text(
                '▲ ~ ',
                style: GoogleFonts.sourceCodePro(
                  fontSize: 14,
                  color: white,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Flexible(
                child: TextField(
                  controller: prov.tec,
                  autofocus: true,
                  style: GoogleFonts.sourceCodePro(
                    color: white,
                    fontSize: 14,
                  ),
                  onSubmitted: (s) {
                    prov.cmd(s);
                  },
                  cursorColor: white,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
             
            ],
          ),
        ],
      ),
    );
  }
}
