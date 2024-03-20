/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package com.facebook.yoga;

public abstract class YogaNodeFactory {
  public static FlexNode create() {
    return new YogaNodeJNIFinalizer();
  }

  public static FlexNode create(YogaConfig config) {
    return new YogaNodeJNIFinalizer(config);
  }
}
