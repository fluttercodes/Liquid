// Copyright (c) 2020, the Liquid project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'liquid_layout.dart';

extension MediaQueryDataExtension on MediaQueryData {
  bool get isXS => size.width < kSMBreakPoint;
  bool get isSM => size.width >= kSMBreakPoint && size.width < kMDBreakPoint;
  bool get isMD => size.width >= kMDBreakPoint && size.width < kLGBreakPoint;
  bool get isLG => size.width >= kLGBreakPoint && size.width < kXLBreakPoint;
  bool get isXL => size.width >= kXLBreakPoint;

  LBreakPoint get activeBreakpoint {
    if (size.width >= kXLBreakPoint) return LBreakPoint.xl;
    if (size.width >= kLGBreakPoint) return LBreakPoint.lg;
    if (size.width >= kMDBreakPoint) return LBreakPoint.md;
    if (size.width >= kSMBreakPoint) return LBreakPoint.sm;
    return LBreakPoint.xs;
  }
}
