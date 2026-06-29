#!/usr/bin/env swift
import AppKit
import Foundation
import ImageIO
import Vision

struct Failure: Error, CustomStringConvertible {
    let description: String
}

func run() throws {
    let args = CommandLine.arguments
    guard args.count >= 4 else {
        throw Failure(description: "usage: verify_screenshot.swift <image> <width> <height> [expected text...]")
    }

    let imageURL = URL(fileURLWithPath: args[1])
    let expectedWidth = Int(args[2]) ?? 0
    let expectedHeight = Int(args[3]) ?? 0
    let expectedText = Array(args.dropFirst(4))

    guard let source = CGImageSourceCreateWithURL(imageURL as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
        throw Failure(description: "could not read image: \(imageURL.path)")
    }

    let width = image.width
    let height = image.height
    guard width == expectedWidth, height == expectedHeight else {
        throw Failure(description: "unexpected dimensions: \(width)x\(height), expected \(expectedWidth)x\(expectedHeight)")
    }

    try verifyNonBlank(image)

    if !expectedText.isEmpty {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["en-US", "zh-Hans", "ja-JP"]

        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try handler.perform([request])

        let recognized = (request.results ?? [])
            .compactMap { $0.topCandidates(1).first?.string }
            .joined(separator: "\n")

        for expected in expectedText {
            guard recognized.localizedCaseInsensitiveContains(expected) else {
                throw Failure(description: "missing expected text '\(expected)'; OCR saw: \(recognized.prefix(500))")
            }
        }
    }

    print("ok \(width)x\(height)")
}

func verifyNonBlank(_ image: CGImage) throws {
    let sampleWidth = 24
    let sampleHeight = 24
    var pixels = [UInt8](repeating: 0, count: sampleWidth * sampleHeight * 4)
    guard let context = CGContext(
        data: &pixels,
        width: sampleWidth,
        height: sampleHeight,
        bitsPerComponent: 8,
        bytesPerRow: sampleWidth * 4,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        throw Failure(description: "could not create sampling context")
    }
    context.draw(image, in: CGRect(x: 0, y: 0, width: sampleWidth, height: sampleHeight))

    var minValue = 255
    var maxValue = 0
    for index in stride(from: 0, to: pixels.count, by: 4) {
        let brightness = (Int(pixels[index]) + Int(pixels[index + 1]) + Int(pixels[index + 2])) / 3
        minValue = min(minValue, brightness)
        maxValue = max(maxValue, brightness)
    }

    guard maxValue - minValue > 20 else {
        throw Failure(description: "screenshot appears blank or nearly uniform")
    }
}

do {
    try run()
} catch {
    fputs("verify_screenshot: \(error)\n", stderr)
    exit(1)
}
