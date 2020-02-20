//
//  RGBAMatcher.swift
//  XcodeColorSense
//
//  Created by Khoa Pham on 17/05/16.
//  Copyright © 2016 Fantageek. All rights reserved.
//

import Cocoa

struct RGBAMatcher: Matcher {

  func check(line: String, selectedText: String) -> (color: NSColor, range: NSRange)? {
    guard line.contains("UIColor") || line.contains("NSColor") else { return nil }

    let range = (line as NSString).range(of: "red")

    guard let red = find(component: "red", line: line),
        let green = find(component: "green", line: line),
        let blue = find(component: "blue", line: line), range.length > 0
      else { return nil }

    let alpha = find(component: "alpha", line: line) ?? 1.0
    let color = NSColor(red: red, green: green, blue: blue, alpha: alpha)

    return (color: color, range: range)
  }

  func find(component: String, line: String) -> CGFloat? {
    let pattern = "\(component)\\s*:\\s*[0-9]*\\.?[0-9]*f?\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?"
    guard let range = Regex.check(string: line, pattern: pattern) else { return nil }

    let string = (line as NSString)
        .substring(with: range)
        .remove(occurrence: component)
        .remove(occurrence: ":")
        .remove(occurrence: "f")
      .trim()

    let parts = (string.components(separatedBy: "/")).compactMap {
      return Float($0.trim())
    }

    switch parts.count {
    case 1:
      return CGFloat(parts[0])
    case 2:
      let divisor = parts[1] != 0 ? parts[1] : 1
      return CGFloat(parts[0]) / CGFloat(divisor)
    default:
      return nil
    }
  }
}
