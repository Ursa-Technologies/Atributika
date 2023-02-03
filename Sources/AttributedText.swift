/**
 *  Atributika
 *
 *  Copyright (c) 2017 Pavel Sharanda. Licensed under the MIT license, as follows:
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 */

import Foundation

public enum DetectionType {
    case tag(Tag)
    case hashtag(String)
    case mention(String)
    case regex(String)
    case phoneNumber(String)
    case link(URL)
    case textCheckingType(String, NSTextCheckingResult.CheckingType)
    case range
    case symbol(String)
    case keyword(String)
}

public struct Detection {
    public let type: DetectionType
    public let style: Style
    public var range: Range<String.Index>
    public let isKeyword: Bool
    let level: Int
}

public protocol AttributedTextProtocol {
    var string: String {get}
    var highlightedString: String {get}
    var detections: [Detection] {get}
    var highlightedDetections: [Detection] {get}
    var baseStyle: Style {get}
}

typealias AttributesBlock = (Style) -> [AttributedStringKey: Any]

extension AttributedTextProtocol {

    fileprivate func makeAttributedString(getAttributes: AttributesBlock) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: highlightedString, attributes: getAttributes(baseStyle))

        let sortedDetections = highlightedDetections.sorted { $0.level < $1.level }

        for d in sortedDetections {
            let attrs = getAttributes(d.style)
            if attrs.count > 0 {
                attributedString.addAttributes(attrs, range: NSRange(d.range, in: string))
            }
        }

        return attributedString
    }
}

public final class AttributedText: AttributedTextProtocol {
    public let string: String
    public let highlightedString: String
    public let detections: [Detection]
    public let highlightedDetections: [Detection]
    public let baseStyle: Style

    init(string: String, detections: [Detection], baseStyle: Style) {
        self.string = string
        self.detections = detections
        self.baseStyle = baseStyle

        let sortedDetections = detections.sorted { $0.range.lowerBound < $1.range.lowerBound }

        var ranges: [String: Range<String.Index>] = [:]
        var offset = 0
        var fString = string
        for detection in sortedDetections {
            if ranges["\(detection)"] != nil {
                continue
            }
            var range = detection.range

            // Step Forward for each previous Keyword
            let nsrange = NSRange(detection.range, in: string)
            let newLower = string.index(range.lowerBound, offsetBy: -offset)
            range = newLower ..< string.index(newLower, offsetBy: nsrange.length)

            if detection.isKeyword {
                // Remove the ?
                fString.remove(at: range.lowerBound)
                // Shrink the range by one
                range = range.lowerBound ..< AttributedText.beforeOrEnd(fString, bound: range.upperBound)
                // Remove any _
                fString = fString.replacingOccurrences(of: "_", with: " ", options: [], range: range)
                offset += 1
            }

            // Don't double run this
            ranges["\(detection)"] = range
        }

        var detectionDict: [String: Detection] = [:]
        for d in detections {
            if let range = ranges["\(d)"] {
                detectionDict["\(d)"] = Detection(type: d.type, style: d.style, range: range, isKeyword: d.isKeyword, level: d.level)
            }
        }

        self.highlightedDetections = detectionDict.values.sorted { $0.level < $1.level }
        self.highlightedString = fString
    }

    static func beforeOrEnd(_ string: String, bound: String.Index) -> String.Index {
        return string.endIndex < bound ? string.endIndex : string.index(before: bound)
    }

    public lazy private(set) var attributedString: NSAttributedString  = {
        makeAttributedString { $0.attributes }
    }()

    public lazy private(set) var disabledAttributedString: NSAttributedString  = {
        makeAttributedString { $0.disabledAttributes }
    }()
}

extension AttributedTextProtocol {

    /// style the whole string
    public func styleAll(_ style: Style) -> AttributedText {
        return AttributedText(string: string, detections: detections, baseStyle: baseStyle.merged(with: style))
    }

    /// style things like #xcode #mentions
    public func styleHashtags(_ style: Style) -> AttributedText {
        let ranges = string.detectHashTags()
        let ds = ranges.map { Detection(type: .hashtag(String(string[(string.index($0.lowerBound, offsetBy: 1))..<$0.upperBound])), style: style, range: $0, isKeyword: false, level: Int.max) }
        return AttributedText(string: string, detections: detections + ds, baseStyle: baseStyle)
    }

    /// style things like @John @all
    public func styleMentions(_ style: Style) -> AttributedText {
        let ranges = string.detectMentions()
        let ds = ranges.map { Detection(type: .mention(String(string[(string.index($0.lowerBound, offsetBy: 1))..<$0.upperBound])), style: style, range: $0, isKeyword: false, level: Int.max) }
        return AttributedText(string: string, detections: detections + ds, baseStyle: baseStyle)
    }

    /// style things like $AAPL
    public func styleSymbols(_ style: Style) -> AttributedText {
        let ranges = string.detectSymbols()
        let ds = detections + ranges.map {
            Detection(type: .symbol(String(string[string.index($0.lowerBound, offsetBy: 1)..<$0.upperBound])), style: style, range: $0, isKeyword: false, level: Int.max)
        }
        return AttributedText(string: string, detections: detections + ds, baseStyle: baseStyle)
    }

    /// style things like ?keyword_keyword
    public func styleKeywords(_ style: Style) -> AttributedText {
        let ranges = string.detectKeywords()
        let ds = detections + ranges.map {
            Detection(type: .keyword(String(string[string.index($0.lowerBound, offsetBy: 1)..<$0.upperBound])), style: style, range: $0, isKeyword: true, level: Int.max)
        }
        return AttributedText(string: string, detections: detections + ds, baseStyle: baseStyle)
    }

    public func style(regex: String, options: NSRegularExpression.Options = [], style: Style) -> AttributedText {
        let ranges = string.detect(regex: regex, options: options)
        let ds = ranges.map { Detection(type: .regex(regex), style: style, range: $0, isKeyword: false, level: Int.max) }
        return AttributedText(string: string, detections: detections + ds, baseStyle: baseStyle)
    }

    public func style(textCheckingTypes: NSTextCheckingResult.CheckingType, style: Style) -> AttributedText {
        let ranges = string.detect(textCheckingTypes: textCheckingTypes)
        let ds = ranges.map { Detection(type: .textCheckingType(String(string[$0]), textCheckingTypes), style: style, range: $0, isKeyword: false, level: Int.max) }
        return AttributedText(string: string, detections: detections + ds, baseStyle: baseStyle)
    }

    public func stylePhoneNumbers(_ style: Style) -> AttributedText {
        let ranges = string.detect(textCheckingTypes: [.phoneNumber])
        let ds = ranges.map { Detection(type: .phoneNumber(String(string[$0])), style: style, range: $0, isKeyword: false, level: Int.max) }
        return AttributedText(string: string, detections: detections + ds, baseStyle: baseStyle)
    }

    public func styleLinks(_ style: Style) -> AttributedText {
        let ranges = string.detect(textCheckingTypes: [.link])

        #if swift(>=4.1)
        let ds = ranges.compactMap { range in
            URL(string: String(string[range])).map { Detection(type: .link($0), style: style, range: range, isKeyword: false, level: Int.max) }
        }
        #else
        let ds = ranges.flatMap { range in
            URL(string: String(string[range])).map { Detection(type: .link($0), style: style, range: range) }
        }
        #endif

        return AttributedText(string: string, detections: detections + ds, baseStyle: baseStyle)
    }

    public func style(range: Range<String.Index>, style: Style) -> AttributedText {
        let d = Detection(type: .range, style: style, range: range, isKeyword: false, level: Int.max)
        return AttributedText(string: string, detections: detections + [d], baseStyle: baseStyle)
    }
}

extension String: AttributedTextProtocol {

    public var string: String {
        return self
    }

    public var highlightedString: String {
        return self
    }

    public var detections: [Detection] {
        return []
    }

    public var highlightedDetections: [Detection] {
        return []
    }

    public var baseStyle: Style {
        return Style()
    }

    public func style(tags: [Style], transformers: [TagTransformer] = [TagTransformer.brTransformer], tuner: (Style, Tag) -> Style = { s, _ in return  s}) -> AttributedText {
        let (string, tagsInfo) = detectTags(transformers: transformers)

        var ds: [Detection] = []

        tagsInfo.forEach { t in

            if let style = (tags.first { style in style.name.lowercased() == t.tag.name.lowercased() }) {
                ds.append(Detection(type: .tag(t.tag), style: tuner(style, t.tag), range: t.range, isKeyword: false, level: t.level))
            } else {
                ds.append(Detection(type: .tag(t.tag), style: Style(), range: t.range, isKeyword: false, level: t.level))
            }
        }

        return AttributedText(string: string, detections: ds, baseStyle: baseStyle)
    }

    public func style(tags: Style..., transformers: [TagTransformer] = [TagTransformer.brTransformer], tuner: (Style, Tag) -> Style = { s, _ in return  s}) -> AttributedText {
        return style(tags: tags, transformers: transformers, tuner: tuner)
    }

    public var attributedString: NSAttributedString {
        return makeAttributedString { $0.attributes }
    }

    public var disabledAttributedString: NSAttributedString {
        return makeAttributedString { $0.disabledAttributes }
    }
}

extension NSAttributedString: AttributedTextProtocol {
    public var highlightedString: String {
        return string
    }

    public var detections: [Detection] {
        var ds: [Detection] = []

        enumerateAttributes(in: NSMakeRange(0, length), options: []) { (attributes, range, _) in
            if let range = Range(range, in: self.string) {
                ds.append(Detection(type: .range, style: Style("", attributes), range: range, isKeyword: false, level: Int.max))
            }
        }

        return ds
    }


    public var highlightedDetections: [Detection] {
        return detections
    }

    public var baseStyle: Style {
        return Style()
    }

    public var attributedString: NSAttributedString {
        return makeAttributedString { $0.attributes }
    }

    public var disabledAttributedString: NSAttributedString {
        return makeAttributedString { $0.disabledAttributes }
    }
}
