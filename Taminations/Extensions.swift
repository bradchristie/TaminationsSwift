//
// Created by Bradley Christie on 2019-02-15.
//

import UIKit

extension Int {

  var d:Double { get { return Double(self) } }
  var cg:CGFloat { get { return CGFloat(self) } }
  var s:String { get { return "\(self)" } }
  var abs:Int { get { return self < 0 ? -self : self } }
  var isEven:Bool { get { return self % 2 == 0 } }
  var isOdd:Bool { get { return self % 2 == 1 } }

}

extension Float {

  var d:Double { get { return Double(self) } }

}

extension CGFloat {

  var i:Int { get { return Int(self) } }
  var d:Double { get { return Double(self) } }
  var s:String { get { return "\(self)" } }

}

extension Double {

  var s:String { return "\(self)" }
  var i:Int { return Int(self) }
  var f:Float { return Float(self) }
  var cg:CGFloat { return CGFloat(self) }
  var sign:Double { return self < 0.0 ? -1.0 : self > 0.0 ? 1.0 : 0.0 }
  var Ceil:Double { return ceil(self) }
  var abs:Double { return self < 0 ? -self : self }
  var Sqrt:Double { return sqrt(self) }
  var sq:Double { return self * self }
  var Sin:Double { return sin(self) }
  var Cos:Double { return cos(self) }
  var toRadians:Double { return self * .pi / 180 }
  func isApproxInt(delta:Double=0.1) -> Bool { return (self - self.rounded()).abs < delta }
  func isApprox(_ y:Double, delta:Double=0.1) -> Bool { return (self-y).abs < delta }
  func angleDiff(_ a2:Double) -> Double {
    return ((((self-a2).truncatingRemainder(dividingBy:.pi*2)) + (.pi*3)).truncatingRemainder(dividingBy: (.pi*2))) - .pi
  }
  func angleEquals(_ a2:Double) -> Bool {
    return angleDiff(a2).isApprox(0.0)
  }
  func isAround(_ a2:Double) -> Bool {
    return angleEquals(a2)
  }

}

//  Swift seems to be missing a logical XOR
func ^(b1:Bool, b2:Bool) -> Bool {
  return b1 ? !b2 : b2
}

extension Array {

  func isNotEmpty() -> Bool {
    return !isEmpty
  }

  func last() -> Element {
    return self[self.count-1]
  }

  func lastOrNull() -> Element? {
    return self.count > 0 ? last() : nil
  }

  func mapIndexed<T>(_ f:(Int,Element) -> T ) -> [T] {
    return self.enumerated().map { (i,it) in f(i,it) }
  }

  func any(_ f:(Element) throws -> Bool) rethrows -> Bool {
    return try first(where:f) != nil
  }
  func none(_ f:(Element) -> Bool) -> Bool {
    return !any(f)
  }
  func all(_ f:(Element) throws -> Bool) rethrows -> Bool {
    return try allSatisfy(f)
  }

  func sortedBy<T:Comparable>(_ f:(Element) -> T) -> [Element] {
    return self.sorted { (a,b) in f(a) < f(b) }
  }

  func drop(_ n:Int) -> [Element] {
    return Array(self[n...])
  }
  //func dropLast(_ n:Int) -> [Element] {
  //  return Array(self[...(count-n-1)])
 // }

  func filterNot(_ f:(Element)->Bool) -> [Element] {
    return filter { e in !f(e) }
  }

  func elementAtOrNull(_ i:Int) -> Element? {
    return i >= 0 && i < count ? self[i] : nil
  }


  var second:Element? { return self[1] }

}

extension Array where Array.Element : Equatable {

  func distinct() -> [Element] {
    var a:[Element] = []
    for e in self {
      if (!a.contains { x in x == e } ) {
        a.append(e)
      }
    }
    return a
  }

  func containsAll(_ a:[Element]) -> Bool {
    return a.all { a1 in contains { x in x == a1 } }
  }

}


extension String {

  var i: Int { get { return isBlank ? 0 : Int(self)! } }
  var d:Double { get { return Double(self)! } }

  func isNotEmpty() -> Bool {
    return !isEmpty
  }

  func trim() -> String {
    return self.trimmingCharacters(in: .whitespaces)
  }

  var isBlank: Bool {
    get {
      return self.trim().isEmpty
    }
  }

  func replaceAll(_ query: String, _ replacement: String) -> String {
    return self.replacingOccurrences(of: query, with: replacement,
      options: .regularExpression, range: nil)
  }
  func replaceFirst(_ query:String, _ replacement:String) -> String {
    var retval = self
    if let r = range(of: query, options: .regularExpression) {
      retval.replaceSubrange(r, with: replacement)
    }
    return retval
  }

  func split() -> [String] {
    return components(separatedBy: CharacterSet.whitespaces)
  }

  func split(_ c: String, maxSplits:Int = 0) -> [String] {
    let comps = components(separatedBy: c)
    if (maxSplits > 1 && maxSplits < comps.count) {
      return comps[...(maxSplits-2)] + [comps[(maxSplits-1)...].joined(separator:c)]
    }
    return comps
  }

  // Returns an array of strings, starting with the entire string,
  // and each subsequent string chopping one word off the end
  func chopped() -> [String] {
    var ss = [String]()
    return split().map { (s:String) -> String in
        ss.append(s)
        return ss.reduce("",{ "\($0) \($1)" }).trim()
      } .reversed()
  }

  // Return an array of strings, each removing one word from the start
  func diced() -> [String] {
    var ss = [String]()
    return split().reversed().map { (s:String) -> String in
        ss.insert(s, at: 0)
        return ss.reduce("",{ "\($0) \($1)" }).trim()
      } .reversed()
  }

  /**
   *   Return all combinations of words from a string
   */
  func minced() -> [String] {
    return chopped().flatMap { (s:String) -> [String] in s.diced() }
  }

  /**
   * Tests whether this string matches the given regularExpression. This method returns
   * true only if the regular expression matches the <i>entire</i> input string. */
  func matches(_ query:String) -> Bool {
    return range(of: "^("+query+")$", options: .regularExpression) != nil
  }
  //  And this one can match any substring
  func contains(_ query:String) -> Bool {
    return range(of: query, options: .regularExpression) != nil
  }

  func replace(_ query: String, _ replacement: String) -> String {
    return self.replacingOccurrences(of: query, with: replacement)
  }

  //  Quote a string and escape any internal quotes
  func quote() -> String {
    return "\"\(replace("\"","&quot;"))\""
  }


// Match regex with groups
  func matchesWithGroups(_ regexPattern: String) -> [[String]] {
    do {
      let text = self
      let regex = try NSRegularExpression(pattern: regexPattern)
      let matches = regex.matches(in: text,
        range: NSRange(text.startIndex..., in: text))
      return matches.map { match in
        (0..<match.numberOfRanges).map {
          let rangeBounds = match.range(at: $0)
          guard let range = Range(rangeBounds, in: text) else {
            return ""
          }
          return String(text[range])
        }
      }
    } catch let error {
      print("invalid regex: \(error.localizedDescription)")
      return []
    }
  }
  //  Return the first match with groups
  func matchWithGroups(_ regexPattern: String) -> [String]? {
    return matchesWithGroups(regexPattern).first
  }

  func startsWith(_ query:String) -> Bool {
    return starts(with:query)
  }
  func endsWith(_ query:String) -> Bool {
    return reversed().starts(with:query.reversed())
  }

  //  Return string with (almost) every word capitalized
  func capWords() -> String {
    return self.split().map { s in
      let cap = s.lowercased().capitalized
      switch (cap) {
        case "And": return "and"
        case "A": return "a"
        case "An": return "an"
        case "At": return "at"
        case "To": return "to"
        case "The": return "the"
        default: return cap
      }
    }.joined(separator: " ")
  }

  func encodeURI() -> String {
    return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
  }

  func decodeURI() -> String {
    return self.removingPercentEncoding!
  }
}

extension UIFont {

  /**
   Will return the best font conforming to the descriptor which will fit in the provided bounds.
   */
  static func bestFittingFontSize(for text: String, in bounds: CGRect, fontDescriptor: UIFontDescriptor,
                                  additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> CGFloat {
    let constrainingDimension = min(bounds.width, bounds.height)
    let properBounds = CGRect(origin: .zero, size: bounds.size)
    var attributes = additionalAttributes ?? [:]

    let infiniteBounds = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
    var bestFontSize: CGFloat = constrainingDimension

    for fontSize in stride(from: bestFontSize, through: 0, by: -1) {
      let newFont = UIFont(descriptor: fontDescriptor, size: fontSize)
      attributes[.font] = newFont

      let currentFrame = text.boundingRect(with: infiniteBounds, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)

      if properBounds.contains(currentFrame) {
        bestFontSize = fontSize
        break
      }
    }
    return bestFontSize
  }

  static func bestFittingFont(for text: String, in bounds: CGRect, fontDescriptor: UIFontDescriptor,
                              additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> UIFont {
    let bestSize = bestFittingFontSize(for: text, in: bounds, fontDescriptor: fontDescriptor, additionalAttributes: additionalAttributes)
    return UIFont(descriptor: fontDescriptor, size: bestSize)
  }
}

extension UILabel {

  /// Will auto resize the contained text to a font size which fits the frames bounds.
  /// Uses the pre-set font to dynamically determine the proper sizing
  func fitTextToBounds() {
    guard let text = text, let currentFont = font else { return }

    let bestFittingFont = UIFont.bestFittingFont(for: text, in: bounds, fontDescriptor: currentFont.fontDescriptor,
      additionalAttributes: basicStringAttributes)
    font = bestFittingFont
  }

  private var basicStringAttributes: [NSAttributedString.Key: Any] {
    var attribs = [NSAttributedString.Key: Any]()

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = self.textAlignment
    paragraphStyle.lineBreakMode = self.lineBreakMode
    attribs[.paragraphStyle] = paragraphStyle

    return attribs
  }

}
