import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

List<Color> bgColors(context) {
  return [
    Theme.of(context).scaffoldBackgroundColor,
    const Color(0xFFF28C82),
    const Color(0xFFFABD03),
    const Color(0xFFFFF476),
    const Color(0xFFCDFF90),
    const Color(0xFFA7FEEB),
    const Color(0xFFCBF0F8),
    const Color(0xFFAFCBFA),
    const Color(0xFFD7AEFC),
    const Color(0xFFFDCFE9),
    const Color(0xFFE6C9A9),
    const Color(0xFFE9EAEE),
  ];
}

Future<Color> fgColorPicker({required context, required initialcolor}) async {
  Color selectedColor = initialcolor;

  await showDialog(
      context: context,
      builder: (context) => SimpleDialog(
            children: [
              MaterialColorPicker(
                allowShades: false,
                circleSize: 35,
                onMainColorChange: (newColor) {
                  selectedColor = newColor!;
                },
                physics: const BouncingScrollPhysics(),
                selectedColor: selectedColor,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        selectedColor = initialcolor;
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Select')),
                ],
              )
            ],
          ));
  return selectedColor;
}

Future<Color> bgColorPicker({
  required context,
  required Color initialColor,
}) async {
  var selectedColor = initialColor;
  await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
            builder: (context, setState) => SimpleDialog(
              contentPadding: const EdgeInsets.only(left: 12.0, top: 12.0),
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: bgColors(context)
                      .map((color) => Container(
                            margin:
                                const EdgeInsets.only(right: 5.0, bottom: 5.0),
                            decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(35.0))),
                            child: CircleColor(
                              color: color,
                              circleSize: 35.0,
                              iconSelected: Icons.check,
                              onColorChoose: (newColor) {
                                selectedColor = newColor;
                                setState(() {});
                              },
                              isSelected: color == selectedColor,
                            ),
                          ))
                      .toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                        onPressed: () {
                          selectedColor = initialColor;
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Select')),
                  ],
                )
              ],
            ),
          ));
  return selectedColor;
}
