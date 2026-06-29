#!/usr/bin/env swift
import AppKit
import Foundation

let args = CommandLine.arguments
guard args.count >= 4 else {
    fatalError("usage: make_contact_sheet.swift <output.png> <label=image> ...")
}

let output = URL(fileURLWithPath: args[1])
let pairs = args.dropFirst(2).compactMap { arg -> (String, NSImage)? in
    let pieces = arg.split(separator: "=", maxSplits: 1).map(String.init)
    guard pieces.count == 2, let image = NSImage(contentsOfFile: pieces[1]) else {
        return nil
    }
    return (pieces[0], image)
}

let thumbWidth: CGFloat = 320
let labelHeight: CGFloat = 32
let padding: CGFloat = 18
let totalWidth = CGFloat(pairs.count) * thumbWidth + CGFloat(max(0, pairs.count - 1)) * padding + padding * 2
let maxThumbHeight = pairs.map { pair in
    thumbWidth * pair.1.size.height / pair.1.size.width
}.max() ?? 0
let totalHeight = maxThumbHeight + labelHeight + padding * 2

let canvas = NSImage(size: NSSize(width: totalWidth, height: totalHeight))
canvas.lockFocus()
NSColor(calibratedRed: 0.95, green: 0.93, blue: 0.88, alpha: 1).setFill()
NSBezierPath(rect: NSRect(origin: .zero, size: canvas.size)).fill()

let attributes: [NSAttributedString.Key: Any] = [
    .font: NSFont.boldSystemFont(ofSize: 15),
    .foregroundColor: NSColor(calibratedRed: 0.11, green: 0.12, blue: 0.14, alpha: 1)
]

for (index, pair) in pairs.enumerated() {
    let x = padding + CGFloat(index) * (thumbWidth + padding)
    let thumbHeight = thumbWidth * pair.1.size.height / pair.1.size.width
    let imageRect = NSRect(x: x, y: padding + labelHeight, width: thumbWidth, height: thumbHeight)
    pair.1.draw(in: imageRect)
    pair.0.draw(in: NSRect(x: x, y: padding, width: thumbWidth, height: labelHeight), withAttributes: attributes)
}

canvas.unlockFocus()

guard let tiff = canvas.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let data = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("could not render contact sheet")
}

try data.write(to: output)
print(output.path)
