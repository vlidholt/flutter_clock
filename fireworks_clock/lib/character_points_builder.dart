// Copyright 2020 Viktor Lidholt. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:text_to_path_maker/text_to_path_maker.dart';

class CharacterPointsBuilder {
  PMFont _font;
  Map<String, List<Offset>> _pathCache = {};

  CharacterPointsBuilder({ByteData fontData}) {
    var fontReader = PMFontReader();
    _font = fontReader.parseTTFAsset(fontData);
  }

  List<Offset> generatePointsForCharacter(String character) {
    assert(character.length == 1);

    // Generating the points may take some time, so cache the characters
    // we've already generated points for.
    if (_pathCache[character] != null) return _pathCache[character];

    int charCode = character.codeUnitAt(0);

    // Generate the path for the character.
    var path = _font.generatePathForCharacter(charCode);

    // Flip the path vertically and scale it down.
    var transformMatrix = Matrix4.identity();
    transformMatrix.scale(0.08, -0.08);
    path = path.transform(transformMatrix.storage);

    // Calculate points evenly distributed along the path.
    var pathPieces = _calculatePointsForPath(path);

    // Align the points so that the center of the character is at (0, 0).
    pathPieces = _centerAlignPoints(pathPieces);

    // Save the points in the cache before returning them.
    _pathCache[character] = pathPieces;
    return pathPieces;
  }

  // Get points evenly distributed over a path.
  List<Offset> _calculatePointsForPath(Path path) {
    var metrics = path.computeMetrics();
    var points = <Offset>[];
    var foundPath = false;

    metrics.forEach((metric) {
      // Only get the points for the first path, which is the outline of the
      // character.
      if (foundPath) return;
      foundPath = true;

      // Iterate over the path to find each point.
      for (var i = 0.0; i < 1.0; i += 0.01) {
        points.add(metric.getTangentForOffset(metric.length * i).position);
      }
    });

    return points;
  }

  // Align the points in the list so they are centered around the coordinate
  // systems origin.
  List<Offset> _centerAlignPoints(List<Offset> points) {
    double top;
    double bottom;
    double left;
    double right;

    for (var point in points) {
      if (top == null || top < point.dy) top = point.dy;
      if (bottom == null || bottom > point.dy) bottom = point.dy;
      if (left == null || left < point.dx) left = point.dx;
      if (right == null || right > point.dx) right = point.dx;
    }

    var alignedPoints = <Offset>[];
    double yOffset = -(top + bottom) / 2;
    double xOffset = -(right + left) / 2;

    for (var point in points) {
      alignedPoints.add(
        Offset(point.dx + xOffset, point.dy + yOffset),
      );
    }

    return alignedPoints;
  }
}
