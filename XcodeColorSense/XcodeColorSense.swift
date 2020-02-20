//
//  XcodeColorSense.swift
//
//  Created by Khoa Pham on 16/05/16.
//  Copyright © 2016 Fantageek. All rights reserved.
//

import AppKit

var sharedPlugin: XcodeColorSense?

class XcodeColorSense: NSObject {
    var bundle: Bundle
    lazy var center = NotificationCenter.default
    var textView: NSTextView?
    let previewView = PreviewView(frame: NSRect(origin: CGPoint.zero, size: CGSize(width: 60, height: 40)))
  let matchers: [Matcher] = [
    HexMatcher(),
    PresetMatcher(),
    RGBAMatcher(),
  ]

  // MARK: - Initialization

  class func pluginDidLoad(bundle: Bundle) {
    let allowedLoaders = bundle.object(forInfoDictionaryKey: "me.delisa.XcodePluginBase.AllowedLoaders") as! Array<String>
    if allowedLoaders.contains(Bundle.main.bundleIdentifier ?? "") {
      sharedPlugin = XcodeColorSense(bundle: bundle)
    }
  }

  init(bundle: Bundle) {
    self.bundle = bundle

    super.init()
    // NSApp may be nil if the plugin is loaded from the xcodebuild command line tool
    if (NSApp != nil && NSApp.mainMenu == nil) {
        center.addObserver(self, selector: #selector(applicationDidFinishLaunching), name: NSApplication.didFinishLaunchingNotification, object: nil)
    } else {
      initializeAndLog()
    }
  }

  private func initializeAndLog() {
    let name = bundle.object(forInfoDictionaryKey: "CFBundleName")
    let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString")
    let status = initialize() ? "loaded successfully" : "failed to load"
    NSLog("🔌 Plugin \(name) \(String(describing: version)) \(status)")
  }

    @objc func applicationDidFinishLaunching() {
        center.removeObserver(self, name: NSApplication.didFinishLaunchingNotification, object: nil)
    initializeAndLog()
  }

  func initialize() -> Bool {
    findTextView()
    listenNotification()
    return true
  }

  func findTextView() {
    guard let DVTSourceTextView = NSClassFromString("DVTSourceTextView") as? NSObject.Type,
        let firstResponder = NSApp.keyWindow?.firstResponder, firstResponder.isKind(of: DVTSourceTextView.self)
      else { return }

    textView = firstResponder as? NSTextView
  }

  // MARK: - Notification
  func listenNotification() {
    center.addObserver(self, selector: #selector(handleSelectionChange(note:)), name: NSTextView.didChangeSelectionNotification, object: nil)
  }

    @objc func handleSelectionChange(note: NSNotification) {
        guard let DVTSourceTextView = NSClassFromString("DVTSourceTextView") as? NSObject.Type,
            let theObject = note.object, (theObject as AnyObject).isKind(of: DVTSourceTextView.self),
            let textView = theObject as? NSTextView
        else { return }

        self.textView = textView

        guard let range = textView.selectedRanges.first?.rangeValue,
          let string = textView.textStorage?.string
        else { return }

        // Text
        let text = string as NSString
        let selectedText = text.substring(with: range)
        let lineRange = text.lineRange(for: range)
        let line = text.substring(with: lineRange)

        // Match
        var result: (color: NSColor, range: NSRange)? = nil
        for matcher in matchers {
            if let r = matcher.check(line: line, selectedText: selectedText) {
            result = r
            break
          }
        }

        if let result = result {
          previewView.color = result.color
          textView.addSubview(previewView)

          // Position
          let foundRange = NSMakeRange(lineRange.location + result.range.location, result.range.length)
            let rectInScreen = textView.firstRect(forCharacterRange: foundRange, actualRange: nil)
            let rectInWindow = textView.window?.convertFromScreen(rectInScreen) ?? NSZeroRect
            let rectInTextView = textView.convert(rectInWindow, from: nil)

          previewView.frame.origin = CGPoint(x: rectInTextView.origin.x,
                                             y: rectInTextView.origin.y - previewView.frame.size.height * 2)
        } else {
          previewView.removeFromSuperview()
        }
  }
}

