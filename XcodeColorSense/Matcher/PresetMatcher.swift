//
//  PresetMatcher.swift
//  XcodeColorSense
//
//  Created by Khoa Pham on 17/05/16.
//  Copyright © 2016 Fantageek. All rights reserved.
//

import Cocoa

struct PresetMatcher: Matcher {

  func check(line: String, selectedText: String) -> (color: NSColor, range: NSRange)? {
    guard line.contains("UIColor") || line.contains("NSColor") else { return nil }

    let presets: [String: NSColor] = [
        "blackColor": .black,
      "darkGrayColor": .darkGray,
      "lightGrayColor": .lightGray,
      "whiteColor": .white,
      "grayColor": .gray,
      "redColor": .red,
      "greenColor": .green,
      "blueColor": .blue,
      "cyanColor": .cyan,
      "yellowColor": .yellow,
      "magentaColor": .magenta,
      "orangeColor": .orange,
      "purpleColor": .purple,
      "brownColor": .brown,
      "clearColor": .clear,

      "controlShadowColor": .controlShadowColor,
      "controlDarkShadowColor": .controlDarkShadowColor,
      "controlColor": .controlColor,
    ]

    for preset in presets {
        let range = (line as NSString).range(of: preset.0)
      if range.location != NSNotFound {
        return (color: preset.1, range: range)
      }
    }

    return nil
  }
}
