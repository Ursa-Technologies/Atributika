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
import XCTest
import Atributika

class AtributikaTests: XCTestCase {
    let kwFont = Font.boldSystemFont(ofSize: 1)
    let symFont = Font.boldSystemFont(ofSize: 2)
    let htFont = Font.boldSystemFont(ofSize: 3)
    let menFont = Font.boldSystemFont(ofSize: 4)
    
    func testHello() {        
        let test = "Hello <b>World</b>!!!".style(tags:
            Style("b").font(.boldSystemFont(ofSize: 45))
        ).attributedString
        
        let reference = NSMutableAttributedString(string: "Hello World!!!")
        reference.addAttributes([AttributedStringKey.font: Font.boldSystemFont(ofSize: 45)], range: NSMakeRange(6, 5))
        
        XCTAssertEqual(test,reference)
    }
    
    func testHelloWithBase() {
        
        let test = "<b>Hello World</b>!!!".style(tags: Style("b").font(.boldSystemFont(ofSize: 45)))
            .styleAll(.font(.systemFont(ofSize: 12)))
            .attributedString
        
        let reference = NSMutableAttributedString(string: "Hello World!!!")
        reference.addAttributes([AttributedStringKey.font: Font.boldSystemFont(ofSize: 45)], range: NSMakeRange(0, 11))
        reference.addAttributes([AttributedStringKey.font: Font.systemFont(ofSize: 12)], range: NSMakeRange(11, 3))
        
        XCTAssertEqual(test,reference)
    }
    
    func testTagsWithNumbers() {
        
        let test = "<b1>Hello World</b1>!!!".style(tags: Style("b1").font(.boldSystemFont(ofSize: 45)))
            .styleAll(.font(.systemFont(ofSize: 12)))
            .attributedString
        
        let reference = NSMutableAttributedString(string: "Hello World!!!")
        reference.addAttributes([AttributedStringKey.font: Font.boldSystemFont(ofSize: 45)], range: NSMakeRange(0, 11))
        reference.addAttributes([AttributedStringKey.font: Font.systemFont(ofSize: 12)], range: NSMakeRange(11, 3))
        
        XCTAssertEqual(test,reference)
    }
    
    func testCustomAttributes() {
        
        let test = "<b>Hello World</b>!!!".style(tags: Style("b").custom(1, forAttributedKey: .verticalGlyphForm)).attributedString
        
        let reference = NSMutableAttributedString(string: "Hello World!!!")
        reference.addAttribute(.verticalGlyphForm, value: 1, range: NSMakeRange(0, 11))
        
        XCTAssertEqual(test,reference)

    }
    
    func testLines() {
        
        let test = "<b>Hello\nWorld</b>!!!".style(tags: Style("b").font(.boldSystemFont(ofSize: 45)))
            .styleAll(.font(.systemFont(ofSize: 12)))
            .attributedString
        
        let reference = NSMutableAttributedString(string: "Hello\nWorld!!!")
        reference.addAttributes([AttributedStringKey.font: Font.boldSystemFont(ofSize: 45)], range: NSMakeRange(0, 11))
        reference.addAttributes([AttributedStringKey.font: Font.systemFont(ofSize: 12)], range: NSMakeRange(11, 3))
        
        XCTAssertEqual(test,reference)
    }
    
    func testEmpty() {
        let test = "Hello World!!!".style().attributedString
        
        let reference = NSMutableAttributedString(string: "Hello World!!!")
        
        XCTAssertEqual(test, reference)
    }
    
    func testParams() {
        let a = "<a href=\"http://google.com\">Hello</a> World!!!".style()
        
        let reference = NSMutableAttributedString(string: "Hello World!!!")
        
        XCTAssertEqual(a.attributedString, reference)
        
        XCTAssertEqual(a.detections[0].range, a.string.startIndex..<a.string.index(a.string.startIndex, offsetBy: 5))
        
        if case .tag(let tag) = a.detections[0].type {
            XCTAssertEqual(tag.name, "a")
            XCTAssertEqual(tag.attributes, ["href":"http://google.com"])
            
        }
        
    }
    
    func testBase() {
        let test = "Hello World!!!".styleAll(Style.font(.boldSystemFont(ofSize: 45))).attributedString
        
        let reference = NSMutableAttributedString(string: "Hello World!!!", attributes: [AttributedStringKey.font: Font.boldSystemFont(ofSize: 45)])
        
        XCTAssertEqual(test, reference)
    }
    
    func testManyTags() {
            
        let test = "He<i>llo</i> <b>World</b>!!!".style(tags:
            Style("b").font(.boldSystemFont(ofSize: 45)),
            Style("i").font(.boldSystemFont(ofSize: 12))
        ).attributedString
        
        let reference = NSMutableAttributedString(string: "Hello World!!!")
        reference.addAttributes([AttributedStringKey.font: Font.boldSystemFont(ofSize: 12)], range: NSMakeRange(2, 3))
        reference.addAttributes([AttributedStringKey.font: Font.boldSystemFont(ofSize: 45)], range: NSMakeRange(6, 5))
        
        XCTAssertEqual(test, reference)
    }
    
    func testManySameTags() {
        
        let test = "He<b>llo</b> <b>World</b>!!!".style(tags:
            Style("b").font(.boldSystemFont(ofSize: 45))
        ).attributedString
        
        let reference = NSMutableAttributedString(string: "Hello World!!!")
        reference.addAttributes([AttributedStringKey.font: Font.boldSystemFont(ofSize: 45)], range: NSMakeRange(2, 3))
        reference.addAttributes([AttributedStringKey.font: Font.boldSystemFont(ofSize: 45)], range: NSMakeRange(6, 5))
        
        XCTAssertEqual(test, reference)
    }
    
    func testTagsOverlap() {
        
        let test = "Hello <b>W<red>orld</b>!!!</red>".style(tags:
            Style("b").font(.boldSystemFont(ofSize: 45)),
            Style("red").foregroundColor(.red)
        ).attributedString
        
        let reference = NSMutableAttributedString(string: "Hello World!!!")
        reference.addAttributes([AttributedStringKey.font: Font.boldSystemFont(ofSize: 45)], range: NSMakeRange(6, 5))
        reference.addAttributes([AttributedStringKey.foregroundColor: Color.red], range: NSMakeRange(7, 7))
        
        XCTAssertEqual(test, reference)
    }
    
    func testBr() {
        let test = "Hello<br>World!!!".style(tags: []).attributedString
        
        let reference = NSMutableAttributedString(string: "Hello\nWorld!!!")
        
        XCTAssertEqual(test, reference)
    }
    
    func testNotClosedTag() {
        
        let test = "Hello <b>World!!!".style(tags: Style("b").font(.boldSystemFont(ofSize: 45))).attributedString
        
        let reference = NSMutableAttributedString(string: "Hello World!!!")
        
        XCTAssertEqual(test, reference)
    }
    
    func testNotOpenedTag() {
        
        let test = "Hello </b>World!!!".style(tags: Style("b").font(.boldSystemFont(ofSize: 45))).attributedString
        
        let reference = NSMutableAttributedString(string: "Hello World!!!")
        
        XCTAssertEqual(test, reference)
    }
    
    func testBadTag() {
        
        let test = "Hello <World!!!".style(tags: Style("b").font(.boldSystemFont(ofSize: 45))).attributedString
        
        let reference = NSMutableAttributedString(string: "Hello <World!!!")
        
        XCTAssertEqual(test, reference)
    }
    
    func testTagsStack() {
        
        #if swift(>=4.2)
        let u = Style("u").underlineStyle(.single)
        #else
        let u = Style("u").underlineStyle(.styleSingle)
        #endif
        
        let test = "Hello <b>Wo<red>rl<u>d</u></red></b>!!!"
            .style(tags:
                Style("b").font(.boldSystemFont(ofSize: 45)),
                Style("red").foregroundColor(.red),
                u
        )
        
            .attributedString
        
        let reference = NSMutableAttributedString(string: "Hello World!!!")
        reference.addAttributes([AttributedStringKey.font: Font.boldSystemFont(ofSize: 45)], range: NSMakeRange(6, 5))
        reference.addAttributes([AttributedStringKey.foregroundColor: Color.red], range: NSMakeRange(8, 3))
        
        #if swift(>=4.2)
        reference.addAttributes([AttributedStringKey.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSMakeRange(10, 1))
        #else
        reference.addAttributes([AttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue], range: NSMakeRange(10, 1))
        #endif
        
        
        
        XCTAssertEqual(test, reference)
    }
    
    func testHashCodes() {
        
        let test = "#Hello @World!!!"
            .styleHashtags(Style.font(htFont))
            .styleMentions(Style.font(menFont))
            .attributedString
        
        let reference = NSMutableAttributedString(string: "#Hello @World!!!")
        reference.addAttributes([AttributedStringKey.font: htFont], range: NSMakeRange(0, 6))
        reference.addAttributes([AttributedStringKey.font: menFont], range: NSMakeRange(7, 6))
        
        XCTAssertEqual(test, reference)
    }

    func testSymbols() {
        let test = "\u{2009}hello \u{2009}world \u{2009}AAPL!!!"
            .styleSymbols(Style.font(symFont))
            .attributedString

        let reference = NSMutableAttributedString(string: "\u{2009}hello \u{2009}world \u{2009}AAPL!!!")
        reference.addAttributes([AttributedStringKey.font: symFont], range: NSMakeRange(0, 6))
        reference.addAttributes([AttributedStringKey.font: symFont], range: NSMakeRange(7, 6))
        reference.addAttributes([AttributedStringKey.font: symFont], range: NSMakeRange(14, 5))

        XCTAssertEqual(test, reference)
    }

    func testKeywords() {
        let test = "\u{200A}hello_world!!!"
            .styleKeywords(Style.font(kwFont))
            .attributedString

        let reference = NSMutableAttributedString(string: "\u{200A}hello world!!!")
        reference.addAttributes([AttributedStringKey.font: kwFont], range: NSMakeRange(0, 12))

        XCTAssertEqual(test, reference)
    }

    func testKeywordFollowedByHashtag() {
        let test = "\u{200A}hello_world \u{200A}Y/Y \u{200A}four #Hash!!!"
            .styleKeywords(Style.font(kwFont))
            .styleHashtags(Style.font(htFont))
            .attributedString

        let reference = NSMutableAttributedString(string: "\u{200A}hello world \u{200A}Y/Y \u{200A}four #Hash!!!")
        reference.addAttributes([AttributedStringKey.font: kwFont], range: NSMakeRange(0, 12))
        reference.addAttributes([AttributedStringKey.font: kwFont], range: NSMakeRange(13, 4))
        reference.addAttributes([AttributedStringKey.font: kwFont], range: NSMakeRange(18, 5))
        reference.addAttributes([AttributedStringKey.font: htFont], range: NSMakeRange(24, 5))

        XCTAssertEqual(test, reference)
    }

    func testKeywordWithEmoji() {
        let test = "🎁— Mixed #hash test… \u{200A}hello_world 😁 \u{200A}Y/Y \u{200A}four!!!"
            .styleKeywords(Style.font(kwFont))
            .styleHashtags(Style.font(htFont))
            .attributedString

        let reference = NSMutableAttributedString(string: "🎁— Mixed #hash test… \u{200A}hello world 😁 \u{200A}Y/Y \u{200A}four!!!")
        reference.addAttributes([AttributedStringKey.font: htFont], range: NSMakeRange(10, 5))
        reference.addAttributes([AttributedStringKey.font: kwFont], range: NSMakeRange(22, 12))
        reference.addAttributes([AttributedStringKey.font: kwFont], range: NSMakeRange(38, 4))
        reference.addAttributes([AttributedStringKey.font: kwFont], range: NSMakeRange(43, 5))

        XCTAssertEqual(test, reference)
    }

    func testKeywordWithDash() {
        let test = "\u{2009}Co&ca-Co.la up 2%"
            .styleSymbols(Style.font(symFont))
            .attributedString

        let reference = NSMutableAttributedString(string: "\u{2009}Co&ca-Co.la up 2%")
        reference.addAttributes([AttributedStringKey.font: symFont], range: NSMakeRange(0, 12))

        XCTAssertEqual(test, reference)
    }

    func testKeywordWithUnicode() {
        let test = "\u{2009}MSFT to… \u{200A}acquire #CyberSecurity software RiskIQ for $500M announcing soon. RiskIQ bolsters security capabilities for \u{2009}MSFT's Windows and \u{200A}Azure."
            .styleSymbols(Style.font(symFont))
            .styleKeywords(Style.font(kwFont))
            .styleHashtags(Style.font(htFont))
            .attributedString

        let reference = NSMutableAttributedString(string: "\u{2009}MSFT to… \u{200A}acquire #CyberSecurity software RiskIQ for $500M announcing soon. RiskIQ bolsters security capabilities for \u{2009}MSFT's Windows and \u{200A}Azure.")
        reference.addAttributes([AttributedStringKey.font: symFont], range: NSMakeRange(0, 5))
        reference.addAttributes([AttributedStringKey.font: kwFont], range: NSMakeRange(10, 8))
        reference.addAttributes([AttributedStringKey.font: htFont], range: NSMakeRange(19, 14))
        reference.addAttributes([AttributedStringKey.font: symFont], range: NSMakeRange(119, 5))
        reference.addAttributes([AttributedStringKey.font: kwFont], range: NSMakeRange(139, 6))

        XCTAssertEqual(test, reference)
    }

    func testDoubleKeywordAtEndWithNoPunctuation() {
        let test = "\u{2009}JBL adds new $1B \u{200A}stock_buyback over next 2 years; roughly ~13% of current \u{200A}market_cap"
            .styleSymbols(Style.font(symFont))
            .styleKeywords(Style.font(kwFont))
            .attributedString

        let reference = NSMutableAttributedString(string: "\u{2009}JBL adds new $1B \u{200A}stock buyback over next 2 years; roughly ~13% of current \u{200A}market cap")
        reference.addAttributes([AttributedStringKey.font: symFont], range: NSMakeRange(0, 4))
        reference.addAttributes([AttributedStringKey.font: kwFont], range: NSMakeRange(18, 14))
        reference.addAttributes([AttributedStringKey.font: kwFont], range: NSMakeRange(76, 11))

        XCTAssertEqual(test, reference)
    }

    func testDataDetectorPhoneRaw() {
        
        let test = "Call me (888)555-5512".style(textCheckingTypes: [.phoneNumber],
                                                  style: Style.font(.boldSystemFont(ofSize: 45)))
            .attributedString
        
        let reference = NSMutableAttributedString(string: "Call me (888)555-5512")
        reference.addAttributes([AttributedStringKey.font: Font.boldSystemFont(ofSize: 45)], range: NSMakeRange(8, 13))
        
        XCTAssertEqual(test, reference)
    }
    
    func testDataDetectorLinkRaw() {
        
        let test = "Check this http://google.com".style(textCheckingTypes: [.link],
                                                 style: Style.font(.boldSystemFont(ofSize: 45)))
            .attributedString
        
        let reference = NSMutableAttributedString(string: "Check this http://google.com")
        reference.addAttributes([AttributedStringKey.font: Font.boldSystemFont(ofSize: 45)], range: NSMakeRange(11, 17))
        
        XCTAssertEqual(test, reference)
    }
    
    func testDataDetectorPhone() {
        
        let test = "Call me (888)555-5512".stylePhoneNumbers(Style.font(.boldSystemFont(ofSize: 45)))
            .attributedString
        
        let reference = NSMutableAttributedString(string: "Call me (888)555-5512")
        reference.addAttributes([AttributedStringKey.font: Font.boldSystemFont(ofSize: 45)], range: NSMakeRange(8, 13))
        
        XCTAssertEqual(test, reference)
    }
    
    func testDataDetectorLink() {
        
        let test = "Check this http://google.com".styleLinks(Style.font(.boldSystemFont(ofSize: 45)))
            .attributedString
        
        let reference = NSMutableAttributedString(string: "Check this http://google.com")
        reference.addAttributes([AttributedStringKey.font: Font.boldSystemFont(ofSize: 45)], range: NSMakeRange(11, 17))
        
        XCTAssertEqual(test, reference)
    }
    
    func testIssue1() {
        
        let bad = "<b>Save $1.00</b> on <b>any</b> order!".style(tags:
                Style("b").font(.boldSystemFont(ofSize: 14))
            )
            .styleAll(Style.font(.systemFont(ofSize: 14)).foregroundColor(.red))
            .attributedString
        
        
        
        let badReference = NSMutableAttributedString(string: "Save $1.00 on any order!", attributes: [AttributedStringKey.font: Font.systemFont(ofSize: 14), AttributedStringKey.foregroundColor: Color.red])
        
        badReference.addAttributes([AttributedStringKey.font: Font.boldSystemFont(ofSize: 14)], range: NSMakeRange(0, 10))
        badReference.addAttributes([AttributedStringKey.font: Font.boldSystemFont(ofSize: 14)], range: NSMakeRange(14, 3))
        
        XCTAssertEqual(bad, badReference)
        
        let good = "Save <b>$1.00</b> on <b>any</b> order!".style(tags:
                Style("b").font(.boldSystemFont(ofSize: 14)))
            .styleAll(Style.font(.systemFont(ofSize: 14)).foregroundColor(.red))
            .attributedString
        
        let goodReference = NSMutableAttributedString(string: "Save $1.00 on any order!", attributes: [AttributedStringKey.font: Font.systemFont(ofSize: 14), AttributedStringKey.foregroundColor: Color.red])
        goodReference.addAttributes([AttributedStringKey.font: Font.boldSystemFont(ofSize: 14)], range: NSMakeRange(5, 5))
        goodReference.addAttributes([AttributedStringKey.font: Font.boldSystemFont(ofSize: 14)], range: NSMakeRange(14, 3))
        
        XCTAssertEqual(good, goodReference)
    }
    
    func testRange() {
        let str = "Hello World!!!"
        
        let test = "Hello World!!!".style(range: str.startIndex..<str.index(str.startIndex, offsetBy: 5), style: Style("b").font(.boldSystemFont(ofSize: 45))).attributedString
        
        let reference = NSMutableAttributedString(string: "Hello World!!!")
        reference.addAttributes([AttributedStringKey.font: Font.boldSystemFont(ofSize: 45)], range: NSMakeRange(0, 5))
        
        XCTAssertEqual(test, reference)
    }
    
    func testEmojis() {
        
        let test = "Hello <b>W🌎rld</b>!!!".style(tags:
            Style("b").font(.boldSystemFont(ofSize: 45))
            ).attributedString
        
        let reference = NSMutableAttributedString(string: "Hello W🌎rld!!!")
        reference.addAttributes([AttributedStringKey.font: Font.boldSystemFont(ofSize: 45)], range: NSMakeRange(6, 6))
        
        XCTAssertEqual(test,reference)
    }
    
    func testTransformers() {
        
        let transformers: [TagTransformer] = [
            TagTransformer.brTransformer,
            TagTransformer(tagName: "li", tagType: .start, replaceValue: "- "),
            TagTransformer(tagName: "li", tagType: .end, replaceValue: "\n")
        ]
        
        let li = Style("li").font(.systemFont(ofSize: 12))
        
        let test = "TODO:<br><li>veni</li><li>vidi</li><li>vici</li>"
            .style(tags: li, transformers: transformers)
            .attributedString
        
        let reference = NSMutableAttributedString(string: "TODO:\n- veni\n- vidi\n- vici\n")
        reference.addAttributes([AttributedStringKey.font: Font.systemFont(ofSize: 12)], range: NSMakeRange(6, 6))
        reference.addAttributes([AttributedStringKey.font: Font.systemFont(ofSize: 12)], range: NSMakeRange(13, 6))
        reference.addAttributes([AttributedStringKey.font: Font.systemFont(ofSize: 12)], range: NSMakeRange(20, 6))
        
        XCTAssertEqual(test,reference)
    }

    func testOL() {
        var counter = 0
        let transformers: [TagTransformer] = [
            TagTransformer.brTransformer,
            TagTransformer(tagName: "ol", tagType: .start) { _ in
                counter = 0
                return ""
            },
            TagTransformer(tagName: "li", tagType: .start) { _ in
                counter += 1
                return "\(counter). "
            },
            TagTransformer(tagName: "li", tagType: .end) { _ in
                return "\n"
            }
        ]
        
        let test = "<div><ol type=\"\"><li>Coffee</li><li>Tea</li><li>Milk</li></ol><ol type=\"\"><li>Coffee</li><li>Tea</li><li>Milk</li></ol></div>".style(tags: [], transformers: transformers).string
        let reference = "1. Coffee\n2. Tea\n3. Milk\n1. Coffee\n2. Tea\n3. Milk\n"
        
        XCTAssertEqual(test,reference)
    }
    
    func testStyleBuilder() {
        let s = Style
            .font(.boldSystemFont(ofSize: 12), .normal)
            .font(.systemFont(ofSize: 12), .highlighted)
            .font(.boldSystemFont(ofSize: 13), .normal)
            .foregroundColor(.red, .normal)
            .foregroundColor(.green, .highlighted)

        let ref = Style("", [.normal: [.font: Font.boldSystemFont(ofSize: 13) as Any, .foregroundColor: Color.red as Any],
                   .highlighted: [.font: Font.systemFont(ofSize: 12) as Any,  .foregroundColor: Color.green as Any]])


        XCTAssertEqual("test".styleAll(s).attributedString,"test".styleAll(ref).attributedString)
    }

    func testStyleBuilder2() {
        let s = Style
            .foregroundColor(.red, .normal)
            .font(.boldSystemFont(ofSize: 12), .normal)
            .font(.boldSystemFont(ofSize: 13), .normal)
            .foregroundColor(.green, .highlighted)
            .font(.systemFont(ofSize: 12), .highlighted)

        let ref = Style("", [.normal: [.font: Font.boldSystemFont(ofSize: 13) as Any, .foregroundColor: Color.red as Any],
                             .highlighted: [.font: Font.systemFont(ofSize: 12) as Any,  .foregroundColor: Color.green as Any]])

        XCTAssertEqual("test".styleAll(s).attributedString,"test".styleAll(ref).attributedString)
    }
    
    func testHelloWithRHTMLTag() {
        let test = "\r\n<a style=\"text-decoration:none\" href=\"http://www.google.com\">Hello World</a>".style(tags:
            Style("a").font(.boldSystemFont(ofSize: 45))
            ).attributedString
        
        let reference1 = NSMutableAttributedString.init(string: "Hello World")
        
        XCTAssertEqual(reference1.length, 11)
        XCTAssertEqual(reference1.string.count, 11)
        
        let reference2 = NSMutableAttributedString.init(string: "\rHello World")
        
        XCTAssertEqual(reference2.length, 12)
        XCTAssertEqual(reference2.string.count, 12)
        
        let reference3 = NSMutableAttributedString.init(string: "\r\nHello World")
        
        XCTAssertEqual(reference3.length, 13)
        XCTAssertEqual(reference3.string.count, 12)
        
        reference3.addAttributes([AttributedStringKey.font: Font.boldSystemFont(ofSize: 45)], range: NSRange(reference3.string.range(of: "Hello World")!, in: reference3.string) )
        
        XCTAssertEqual(test, reference3)
    }
    
    func testTagAttributes() {
        let test = "Hello <a class=\"big\" target=\"\" href=\"http://foo.com\">world</a>!"
        
        let (string, tags) = test.detectTags()
        
        
        XCTAssertEqual(string, "Hello world!")
        XCTAssertEqual(tags[0].tag.attributes["class"], "big")
        XCTAssertEqual(tags[0].tag.attributes["target"], "")
        XCTAssertEqual(tags[0].tag.attributes["href"], "http://foo.com")
    }

    func testSelfClosingTagAttributes() {
        let test = "Hello <img href=\"http://foo.com/image.jpg\"/>!"

        let (string, tags) = test.detectTags()

        XCTAssertEqual(string, "Hello !")

        XCTAssertEqual(tags[0].tag.name, "img")
        XCTAssertEqual(tags[0].tag.attributes["href"], "http://foo.com/image.jpg")
    }

    func testInnerSelfClosingTagAttributes() {
        let test = "Hello <b>bold<img href=\"http://foo.com/image.jpg\"/>!</b>"

        let (string, tags) = test.detectTags()

        XCTAssertEqual(string, "Hello bold!")

        XCTAssertEqual(tags[0].tag.name, "img")
        XCTAssertEqual(tags[0].tag.attributes["href"], "http://foo.com/image.jpg")
    }
    
    func testTagAttributesWithSingleQuote() {
        let test = "Hello <a class='big' target='' href=\"http://foo.com\">world</a>!"
        
        let (string, tags) = test.detectTags()
        
        
        XCTAssertEqual(string, "Hello world!")
        XCTAssertEqual(tags[0].tag.attributes["class"], "big")
        XCTAssertEqual(tags[0].tag.attributes["target"], "")
        XCTAssertEqual(tags[0].tag.attributes["href"], "http://foo.com")
    }
    
    func testSpecials() {
        XCTAssertEqual("Hello&amp;World!!!".detectTags().string, "Hello&World!!!")
        XCTAssertEqual("Hello&".detectTags().string, "Hello&")
        XCTAssertEqual("Hello&World".detectTags().string, "Hello&World")
        XCTAssertEqual("&quot;Quote&quot;".detectTags().string, "\"Quote\"")
        XCTAssertEqual("&".detectTags().string, "&")
        XCTAssertEqual("&&amp;".detectTags().string, "&&")
        XCTAssertEqual("4>5".detectTags().string, "4>5")
        XCTAssertEqual("4<5".detectTags().string, "4<5")
        XCTAssertEqual("<".detectTags().string, "<")
        XCTAssertEqual(">".detectTags().string, ">")
        XCTAssertEqual("<a".detectTags().string, "<a")
        XCTAssertEqual("<a>".detectTags().string, "")
        XCTAssertEqual("< a>".detectTags().string, "< a>")        
        XCTAssertEqual("&frasl;".detectTags().string, "⁄")
        XCTAssertEqual("&raquo;".detectTags().string, "»")
    }
    
    func testSpecialCodes() {
        XCTAssertEqual("Fish&#38;Chips".detectTags().string, "Fish&Chips")
        
        XCTAssertEqual("Hello, world.".detectTags().string, "Hello, world.")
        
        XCTAssertEqual("Fish & Chips".detectTags().string, "Fish & Chips")
        
        XCTAssertEqual("My phone number starts with a &#49;".detectTags().string, "My phone number starts with a 1")
        
        XCTAssertEqual("My phone number starts with a &#4_9;!".detectTags().string, "My phone number starts with a &#4_9;!")
        
        XCTAssertEqual("Let's meet at the caf&#xe9;".detectTags().string ,"Let's meet at the café")
        
        XCTAssertEqual("Let's meet at the caf&#xzi;!".detectTags().string, "Let's meet at the caf&#xzi;!")
        
        XCTAssertEqual("What is this character ? -> &#xd8ff;".detectTags().string, "What is this character ? -> &#xd8ff;")
        
        XCTAssertEqual("I love &swift;".detectTags().string ,"I love &swift;")
        
        XCTAssertEqual("Do you know &aleph;?".detectTags().string, "Do you know ℵ?")
        
        XCTAssertEqual("a &amp;&amp; b".detectTags().string, "a && b")
        
        XCTAssertEqual("Going to the &#127482;&#127480; next June".detectTags().string, "Going to the 🇺🇸 next June")
        
    }
    
    func testCaseInsensitive1() {
        
        let test = "<B>Hello World</B>!!!".style(tags: Style("b").font(.boldSystemFont(ofSize: 45)))
            .styleAll(.font(.systemFont(ofSize: 12)))
            .attributedString
        
        let reference = NSMutableAttributedString(string: "Hello World!!!")
        reference.addAttributes([AttributedStringKey.font: Font.boldSystemFont(ofSize: 45)], range: NSMakeRange(0, 11))
        reference.addAttributes([AttributedStringKey.font: Font.systemFont(ofSize: 12)], range: NSMakeRange(11, 3))
        
        XCTAssertEqual(test,reference)
        
    }
    
    func testCaseInsensitive2() {
        
        let test = "<B>Hello World</b>!!!".style(tags: Style("B").font(.boldSystemFont(ofSize: 45)))
            .styleAll(.font(.systemFont(ofSize: 12)))
            .attributedString
        
        let reference = NSMutableAttributedString(string: "Hello World!!!")
        reference.addAttributes([AttributedStringKey.font: Font.boldSystemFont(ofSize: 45)], range: NSMakeRange(0, 11))
        reference.addAttributes([AttributedStringKey.font: Font.systemFont(ofSize: 12)], range: NSMakeRange(11, 3))
        
        XCTAssertEqual(test,reference)
        
    }
    
    func testCaseInsensitiveBr() {
        let test = "Hello<BR>World!!!".style(tags: []).attributedString
        
        let reference = NSMutableAttributedString(string: "Hello\nWorld!!!")
        
        XCTAssertEqual(test, reference)
    }
    
    func testTuner() {
        
        func hexStringToUIColor (hex:String) -> Color {
            var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            
            if (cString.hasPrefix("#")) {
                cString.remove(at: cString.startIndex)
            }
            
            if ((cString.count) != 6) {
                return Color.gray
            }
            
            var rgbValue:UInt32 = 0
            Scanner(string: cString).scanHexInt32(&rgbValue)
            
            return Color(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
            )
        }
        
        let font = Style("font")
        
        let test = "Monday - Friday:<font color=\"#6cc299\"> 8:00 - 19:00</font>".style(tags: font, tuner: { style, tag in
            if tag.name == font.name {
                if let colorString = tag.attributes["color"] {
                    return style.foregroundColor(hexStringToUIColor(hex: colorString))
                }
            }
            return style
        }).attributedString
        
        let reference = NSMutableAttributedString(string: "Monday - Friday: 8:00 - 19:00")
        reference.addAttributes([AttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#6cc299")], range: NSMakeRange(16, 13))
        XCTAssertEqual(test, reference)
    }
    
    func testHrefTuner() {
        
        let a = Style("a")
        
        let test = "<a href=\"https://github.com/psharanda/Atributika\">link</a>".style(tags: a, tuner: { style, tag in
            if tag.name == a.name {
                if let link = tag.attributes["href"] {
                    return style.link(URL(string: link)!)
                }
            }
            return style
        }).attributedString
        
        let reference = NSMutableAttributedString(string: "link")
        reference.addAttributes([AttributedStringKey.link: URL(string: "https://github.com/psharanda/Atributika")!], range: NSMakeRange(0, 4))
        XCTAssertEqual(test, reference)
    }
    
    func testHTMLComment() {
        let test = "Hello <!--This is a comment. Comments are erased by Atributika-->world!"
        
        let (string, tags) = test.detectTags()
        
        
        XCTAssertEqual(string, "Hello world!")
        XCTAssertEqual(tags.count, 0)
    }
    
    func testHTMLComment2() {
        let test = "Hello <!---->world!"
        
        let (string, tags) = test.detectTags()
        
        
        XCTAssertEqual(string, "Hello world!")
        XCTAssertEqual(tags.count, 0)
    }
    
    func testBrokenHTMLComment() {
        let test = "Hello <!-This is a comment. Comments are erased by Atributika-->world!"
        
        let (string, tags) = test.detectTags()
        
        
        XCTAssertEqual(string, test)
        XCTAssertEqual(tags.count, 0)
    }
    
    func testBrokenHTMLComment2() {
        let test = "Hello <!"
        
        let (string, tags) = test.detectTags()
        
        
        XCTAssertEqual(string, test)
        XCTAssertEqual(tags.count, 0)
    }
    
    func testBrokenHTMLComment3() {
        let test = "Hello <!"
        
        let (string, tags) = test.detectTags()
        
        
        XCTAssertEqual(string, test)
        XCTAssertEqual(tags.count, 0)
    }
    
    func testBrokenHTMLComment4() {
        let test = "Hello <!--"
        
        let (string, tags) = test.detectTags()
        
        
        XCTAssertEqual(string, test)
        XCTAssertEqual(tags.count, 0)
    }
    
    func testBrokenHTMLComment5() {
        let test = "Hello <!--This is a comment. Comments are erased by Atributika-d->world!"
        
        let (string, tags) = test.detectTags()
        
        
        XCTAssertEqual(string, test)
        XCTAssertEqual(tags.count, 0)
    }
    
    func testBrokenHTMLComment6() {
        let test = "Hello <!--f"
        
        let (string, tags) = test.detectTags()
        
        
        XCTAssertEqual(string, test)
        XCTAssertEqual(tags.count, 0)
    }
}

#if os(Linux)
extension AtributikaTests {
    static var allTests : [(String, (AtributikaTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
#endif
