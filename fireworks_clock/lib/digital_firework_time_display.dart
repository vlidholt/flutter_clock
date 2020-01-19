// Copyright 2020 Viktor Lidholt. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:intl/intl.dart';

import 'clock_assets.dart';
import 'sprite_nodes/animated_text_node.dart';
import 'sprite_nodes/fireworks_node.dart';

// The coordinate system we are using for the clock, 5/3 proportions.
const _displaySize = Size(500.0, 300.0);

// The amount to shift the phase of the outline each time we draw a digit.
const double _phaseShift = 0.17;

/// Animates and renders the clock.
class DigitalFireworkTimeDisplay extends StatefulWidget {
  final ClockAssets assets;
  final DateTime dateTime;
  final ClockModel model;

  DigitalFireworkTimeDisplay({this.assets, this.dateTime, this.model});

  @override
  State<StatefulWidget> createState() => _CharacterDiplayState();
}

class _CharacterDiplayState extends State<DigitalFireworkTimeDisplay> {
  _DigitalTimeDisplayNode _timeDisplayNode;

  @override
  void initState() {
    super.initState();

    // Setup the root SpriteWorld node, that we are using to animate the clock.
    _timeDisplayNode =
        _DigitalTimeDisplayNode(assets: widget.assets, model: widget.model);

    // Animate the first time.
    _timeDisplayNode.animateTime(widget.dateTime);
  }

  @override
  void didUpdateWidget(DigitalFireworkTimeDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.dateTime != oldWidget.dateTime) {
      // We are changing the time once a second in the parent widget. Tell
      // our time display node to draw a new time.
      _timeDisplayNode.animateTime(widget.dateTime);
    }

    if (widget.model != oldWidget.model) {
      // Update the clock model if it has changed. This adds support for
      // switching to 12 vs 24 h display.
      _timeDisplayNode.model = widget.model;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SpriteWidget(_timeDisplayNode);
  }
}

// This is where most magic happen. The time display node controls the animated
// text that is being rendered, and adds fireworks.
class _DigitalTimeDisplayNode extends NodeWithSize {
  final ClockAssets assets;
  ClockModel model;
  double _phase = 0.0;

  _DigitalTimeDisplayNode({this.assets, this.model}) : super(_displaySize) {
    // Setup the fireworks.
    var fireworks = FireworksNode(
      assets: assets,
      size: _displaySize,
    );
    fireworks.zPosition = 1.0;
    addChild(fireworks);
  }

  // Call once a second to add a new animated time.
  void animateTime(DateTime dateTime) {
    // Generate strings for hour and minutes.
    var hourStr =
        DateFormat(model.is24HourFormat ? 'HH' : 'h').format(dateTime);
    hourStr = hourStr.padLeft(2);
    var minuteStr = DateFormat('mm').format(dateTime);

    // Add animated hour text.
    var animatedHour = AnimatedTextNode(
      assets: assets,
      text: hourStr,
      phase: _phase,
    );
    animatedHour.position =
        Offset(_displaySize.width / 2.0 - 130.0, _displaySize.height / 2.0);
    addChild(animatedHour);

    // Add animated minute text.
    var animatedMinute = AnimatedTextNode(
      assets: assets,
      text: minuteStr,
      phase: _phase,
    );
    animatedMinute.position =
        Offset(_displaySize.width / 2.0 + 130.0, _displaySize.height / 2.0);
    addChild(animatedMinute);

    // Add animated separator.
    var animatedSeparator = AnimatedTextNode(
      assets: assets,
      text: '.',
      phase: _phase,
    );
    animatedSeparator.position =
        Offset(_displaySize.width / 2.0, _displaySize.height / 2.0);
    addChild(animatedSeparator);

    // The text has been animated and fully faded out after two seconds.
    // Remove them from the render tree after this time.
    motions.run(MotionSequence(
      [
        MotionDelay(2.0),
        MotionRemoveNode(animatedHour),
        MotionRemoveNode(animatedMinute),
        MotionRemoveNode(animatedSeparator),
      ],
    ));

    // Update the phase shift, so that we don't start rendering the character
    // in the very same position each time.
    _phase += _phaseShift;
    if (_phase > 1.0) _phase -= 1.0;
  }
}
