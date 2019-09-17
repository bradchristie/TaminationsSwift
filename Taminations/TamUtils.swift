/*

  Taminations Square Dance Animations
  Copyright (C) 2019 Brad Christie

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

import UIKit

struct CallListDatum {
  let title:String
  let norm:String
  let link:String
  let sublevel:String
  let languages:String
  let audio:String
}

class TamUtils {

  //  Hold on to references to docs
  //  as I think they are needed to read their elements
  static let mdoc = TamUtils.getXMLAsset("src/moves")
  static let fdoc = TamUtils.getXMLAsset("src/formations")
  static let calldoc = TamUtils.getXMLAsset("src/calls")
  static var calldata = [CallListDatum]()
  static var callmap = [String:[CallListDatum]]()
  static var words = Set<String>()

  private static var formations = Dictionary<String,XMLElement>()
  private static var moves = Dictionary<String,XMLElement>()

  class func runAfterDelay(_ delay: TimeInterval, block: @escaping ()->()) {
    let time = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: time, execute: block)
  }

  class func getXMLAsset(_ name:String) -> XMLDocument {
    //  Strip off any extension
    let pathparts = (name as NSString).pathComponents
    //  We can assume that the file has just one directory and then the filename
    let path = "files/" + pathparts[0]
    let filename = pathparts[1].split{$0 == "."}.map(String.init)[0]
    let filePath = Bundle.main.path(forResource: filename, ofType: "xml", inDirectory:path)!
    let xmlfile = try! Data(contentsOf: URL(fileURLWithPath: filePath))
    let doc = try! XMLDocument(data: xmlfile)
    return doc
  }

  class func readinitfiles() {
    fdoc.xpath("/formations/formation").forEach { f in
      formations[f.attr("name")!] = f
    }
    mdoc.xpath("/moves/path").forEach { m in
      moves[m.attr("name")!] = m
    }
    //  Read the global list of calls and save in a local list
    //  to speed up searching
    let nodelist = calldoc.xpath("//call")
    calldata = nodelist.map { (n:XMLElement) -> CallListDatum in
      CallListDatum(title: n["title"]!,
        norm: normalizeCall(n["title"]!),
        link: n["link"]!,
        sublevel: "",
        languages: n["languages"] ?? "",
        audio: n["audio"] ?? "")
    }
    calldata.forEach { (data:CallListDatum) -> () in
      data.title.split().forEach { words.insert($0.lowercased()) }
      let norm = data.norm
      if (callmap[norm] == nil) {
        callmap[norm] = [data]
      } else {
        callmap[norm]?.append(data)
      }
    }
    CallContext.loadInitFiles()
  }

  //  Hack to keep working xref from de-allocation
  static var saveXrefdoc:XMLDocument?
  //  Returns animation element, looking up cross-reference if needed.
  class func tamXref(_ tam:XMLElement) -> XMLElement {
    if let link = tam.attr("xref-link") {
      let xtam = TamUtils.getXMLAsset(link)
      saveXrefdoc = xtam
      var s = "//tam"
      if (tam.attr("xref-title") != nil) {
        s += "[@title='\(tam.attr("xref-title")!)']"
      }
      if (tam.attr("xref-from") != nil) {
        s += "[@from='\(tam.attr("xref-from")!)']"
      }
      return xtam.xpath(s).first!
    }
    return tam  // no cross-reference
  }

  class func getFormation(_ fname:String) -> XMLElement {
    return formations[fname]!
  }

  private class func translate(_ elem:XMLElement) -> [Movement] {
    switch (elem.tag) {
      case "path" : return translatePath(elem)
      case "move" : return translateMove(elem)
      case "movement" : return translateMovement(elem)
      default : return []
    }
  }

  //  Takes a path, which is an XML element with children that
  //  are moves or movements.
  //  Returns an array of movements
  class func translatePath(_ pathelem:XMLElement) -> [Movement] {
    let elemlist = pathelem.children.filter{ $0.tag != "path" }
    //  Send the result to translate
    //  to recursively process "move" elements
    return elemlist.flatMap { translate($0) }
  }

  //  Accepts a movement element from a XML file, either an animation definition
  //  or moves.xml
  //  Returns an array of a single movement
  private class func translateMovement(_ move:XMLElement) -> [Movement] {
    return [Movement(elem:move)]
  }

  //  Takes a move, which is an XML element that references another XML
  //  path with its "select" attribute
  //  Returns an array of movements
  private class func translateMove(_ move:XMLElement) -> [Movement] {
    //  First retrieve the requested path
    let movename = move.attr("select")!
    let pathelem = moves[movename]!
    //  Get the list of movements
    let movements = translatePath(pathelem)
    //  Get any modifications
    let scaleX = move.attr("scaleX")?.d ?? 1.0
    let scaleY = (move.attr("scaleY")?.d ?? 1.0) 
              * (move.attr("reflect") == nil ? 1.0 : -1.0)
    let offsetX = move.attr("offsetX")?.d ?? 0.0
    let offsetY = (move.attr("offsetY")?.d ?? 0.0)
    let hands = move.attr("hands") ?? ""
    //  Sum up the total beats so if beats is given as a modification
    //  we know how much to change each movement
    let oldbeats = movements.reduce(0.0, { $0 + $1.beats })
    let beatfactor = (move.attr("beats")?.d ?? oldbeats) / oldbeats
    //  Now go through the movements applying the modifications
    //  The resulting list is the return value
    return movements.map { m in
      m.useHands(hands.isEmpty ? m.hands : Hands.getHands(hands))
      .scale(scaleX,scaleY)
      .skew(offsetX,offsetY)
      .time(m.beats * beatfactor)
    }
  }

  /**
 *   Gets a named path (move) from the file of moves
 */
  class func getMove(_ name:String) -> Path {
    return Path(translate(moves[name]!))
  }

  /**
   *   Returns an array of numbers to use numbering the dancers
   */
  class func getNumbers(_ tam:XMLElement) -> [String] {
    let paths = tam.children(tag: "path")
    var retval = ["1", "2", "3", "4", "5", "6", "7", "8", "", "", "", "", "", "", "", ""]
    let np = min(paths.count,4)
    (0..<paths.count).forEach { i in
      let p = paths[i]
      let n = p.attr("numbers") ?? ""
      if (n.count >= 3) {
        // numbers supplied in animation XML
        retval[i*2] = String(n.first!)
        retval[i*2+1] = String(n.last!)
      }
      else if (i > 3) {
        //  phantoms
        retval[i*2] = " "
        retval[i*2+1] = " "
      } else {
        //  default numbers
        retval[i*2] = (i+1).s
        retval[i*2+1] = (i+1+np).s
      }
    }
    return retval
  }

  class func getCouples(_ tam:XMLElement) -> [String] {
    var retval = ["1","3","1","3",
                  "2","4","2","4",
                  "5","6","5","6",
                  " "," "," "," "]
    let paths = tam.children(tag: "path")
    (0..<paths.count).forEach { i in
      let p = paths[i]
      let c = p.attr("couples") ?? ""
      if (!c.isEmpty) {
        retval[i*2] = String(c.first!)
        retval[i*2+1] = String(c.last!)
      }
    }
    return retval
  }

  /**  Standardize a call name to match against other names  */
  class func normalizeCall(_ callname:String) -> String {
    return callname.lowercased().trim()
      .replaceAll("&","and")
      .replaceAll("\\s+"," ")
      .replaceAll("[^a-zA-Z0-9_ ]","")
      .replaceAll("\\(.*\\)","")
      //  Through => Thru
      .replaceAll("\\bthrou?g?h?\\b","thru")
      //  One and a half
      .replaceAll("(onc?e and a half)|(1 12)|(15)","112")
      //  Process fractions 1/2 3/4 1/4 2/3
      //  Non-alphanums are not used in matching
      //  so these fractions become 12 34 14 23
      //  Fortunately two-digit numbers are not used in calls
      .replaceAll("\\b12|((a|one).)?half\\b","12")
      .replaceAll("\\b(three.quarters?|34)\\b","34")
      .replaceAll("\\b(((a|one).)?quarter|14)\\b","14")
      .replaceAll("\\b23|two.thirds?\\b","23")
      //  One and a half
      .replaceAll("\\b1.5\\b","112")
      //  Process any other numbers
      .replaceAll("\\bzero\\b","0")
      .replaceAll("\\b(1|onc?e)\\b","1")
      .replaceAll("\\b(2|two)\\b","2")
      .replaceAll("\\b(3|three)\\b","3")
      .replaceAll("\\b(4|four)\\b","4")
      .replaceAll("\\b(5|five)\\b","5")
      .replaceAll("\\b(6|six)\\b","6")
      .replaceAll("\\b(7|seven)\\b","7")
      .replaceAll("\\b(8|eight)\\b","8")
      .replaceAll("\\b(9|nine)\\b","9")
      //  Standardize 6 by 2, 6-2, 6 2 Acey Deucey
      .replaceAll("(six|6)\\s*(by)?x?-?\\s*(two|2)","62")
      .replaceAll("(three|3)\\s*(by)?x?-?\\s*(two|2)","32")
      //  'Column' of Magic Column is optional
      .replaceAll("magic (?!column)(?!o)(?!expand)","magic column ")
      //  Use singular form
      .replaceAll("\\b(boy|girl|beau|belle|center|end|point|head|side)s\\b","$1")
      //  Misc other variations
      .replaceAll("\\bswap(\\s+around)?\\b","swap")
      .replaceAll("\\bmen\\b","boy")
      .replaceAll("\\bwomen\\b","girl")
      .replaceAll("\\blead(er)?(ing)?s?\\b","lead")
      .replaceAll("\\btrail(er)?(ing)?s?\\b","trail")
      .replaceAll("\\b(1|3)4 tag the line\\b","$14 tag")
      //  Accept optional "dancers" e.g. "head dancers" == "heads"
      .replaceAll("\\bdancers?\\b","")
      //  Also handle "Lead Couples" as "Leads"
      //  but make sure not to clobber "As Couples" or "Couples Hinge"
      .replaceAll("((head|side|lead|trail|center|end).)couple","$1")

      //  Finally remove non-alphanums and strip spaces
      .replaceAll("\\W","")
      .replaceAll("\\s","")
  }

}
