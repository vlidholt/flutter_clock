// Copyright 2020 Viktor Lidholt. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'character_points_builder.dart';
import 'package:flutter/services.dart';
import 'package:spritewidget/spritewidget.dart';

const _pathFireworkParticle = 'assets/firework-particle.png';
const _pathCharacterStroke = 'assets/character-stroke.png';

class ClockAssets {
  CharacterPointsBuilder get characterPathBuilder => _characterPathBuilder;
  CharacterPointsBuilder _characterPathBuilder;

  SpriteTexture get textureNumberOutline => _textureNumberOutline;
  SpriteTexture _textureNumberOutline;

  SpriteTexture get textureFirework => _textureFirework;
  SpriteTexture _textureFirework;

  ImageMap _images;

  Future<void> load() async {
    // Load a font and setup the points builder
    ByteData fontData = await rootBundle.load('assets/Roboto-Black.ttf');
    _characterPathBuilder = CharacterPointsBuilder(fontData: fontData);

    // Load all image assets
    _images = ImageMap(rootBundle);
    await _images.load([
      _pathCharacterStroke,
      _pathFireworkParticle,
    ]);

    _textureNumberOutline = SpriteTexture(_images[_pathCharacterStroke]);
    _textureFirework = SpriteTexture(_images[_pathFireworkParticle]);
  }
}
