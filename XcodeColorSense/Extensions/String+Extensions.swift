//
//  String+Extensions.swift
//  XcodeColorSense
//
//  Created by Khoa Pham on 17/05/16.
//  Copyright © 2016 Fantageek. All rights reserved.
//

import Foundation

extension String {
  
//  func contains(string: String) -> Bool {
//    return self.contains(string: string)
////    return rangeOfString(string, options: .CaseInsensitiveSearch) != nil
//  }

  func replace(occurence: String, with: String) -> String {
    return replacingOccurrences(of: occurence, with: with)
//    return stringByReplacingOccurrencesOfString(occurence, withString: with)
  }

  func remove(occurrence: String) -> String {
    return replace(occurence: occurrence, with: "")
  }

  func trim() -> String {
    return trimmingCharacters(in: NSCharacterSet.whitespaces)
  }
}
