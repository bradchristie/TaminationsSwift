/*

  Taminations Square Dance Animations
  Copyright (C) 2020 Brad Christie

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

class AbbreviationsModel {

  private let view:AbbreviationsView
  private let initialAbbrev: Dictionary<String, String> = [
    "g": "Girls",
    "b": "Boys",
    "c": "Centers",
    "e": "Ends",
    "h": "Heads",
    "s": "Sides",
    "ct": "Courtesy Turn",
    "hs": "Half Sashay",
    "pt": "Pass Thru",
    "al": "Allemande Left",
    "btl": "Bend the Line",
    "rlg": "Right and Left Grand",
    "rlt": "Right and Left Thru",
    "sq2": "Square Thru 2",
    "sq3": "Square Thru 3",
    "sq4": "Square Thru 4",
    "dpt": "Double Pass Thru",
    "vl": "Veer Left",
    "vr": "Veer Right",
    "x": "Cross",
    "xt": "Extend",
    "fw": "Ferris Wheel",
    "fl": "Flutterwheel",
    "rf": "Reverse Flutterwheel",
    "pto": "Pass the Ocean",
    "st": "Swing Thru",
    "tq": "Touch a Quarter",
    "tb": "Trade By",
    "whd": "Wheel and Deal",
    "wa": "Wheel Around",
    "zo": "Zoom",
    "c34": "Cast Off 3/4",
    "circ": "Circulate",
    "ci": "Centers In",
    "cl": "Cloverleaf",
    "dx": "Dixie Style to a Wave",
    "ht": "Half Tag",
    "ptc": "Pass to the Center",
    "sb": "Scoot Back",
    "stt": "Spin the Top",
    "ttl": "Tag the Line",
    "wad": "Walk and Dodge"
  ]

  init(_ view:AbbreviationsView) {
    self.view = view
    //  Initialize with abbrevs above if 1st time
    if (Storage["+abbrev stored"] == nil) {
      defaultAbbreviations()
      Storage["+abbrev stored"] = "true"
    }
  }

  func clearAbbreviations() {
    Storage.keys.forEach { it in
      if (it.matches("abbrev \\S+")) {
        Storage.remove(it)
      }
    }
    loadAbbreviations()
  }

  func defaultAbbreviations() {
    clearAbbreviations()
    initialAbbrev.forEach { (key: String, value: String) -> () in
      Storage["abbrev \(key)"] = value
    }
    loadAbbreviations()
  }

  func loadAbbreviations() {
    //  Read abbreviations previously stored and fill table
    view.clear()
    Storage.keys.sorted().forEach { key in
      //  skip "*abbrev stored" and any other non-user stuff
      if (key.matches("abbrev \\S+")) {
        view.addItem(key.replace("abbrev ",""),Storage[key]!)
      }
    }
    //  Blank entry at end for writing a new abbrev
    view.addItem("","")
  }

  //  This routine is called when the user presses return
  func saveAbbreviations() {
    //  First remove all the old abbreviations
    Storage.keys.forEach { it in
      if (it.matches("abbrev \\S+")) {
        Storage.remove(it)
      }
    }
    //  Clear any old errors
    view.clearErrors()
    //  Process all the current abbreviations
    (0 ..< view.numItems).forEach { i in
      if (!addOneAbbreviation(view[i].abbr, view[i].expa)) {
        view.markError(i)
      }
    }
    //  Be sure we have a blank row at the bottom
    //  for adding a new abbreviation
    if (!view[view.numItems-1].abbr.isBlank) {
      view.addItem("", "")
    }
  }

  @discardableResult
  func addOneAbbreviation(_ abbr:String, _ expansion:String) -> Bool {
    //  error if duplicate
    if (Storage["abbrev " + abbr] != nil) {
      return false
    }
    //  error if a word used in calls
    else if (TamUtils.words.contains(abbr.lowercased())) {
      return false
    }
    //  ok if a single non-blank string
    else if (abbr.matches("\\S+") && !expansion.isBlank) {
      Storage["abbrev " + abbr] = expansion
      return true
    }
    //  otherwise (embedded spaces) error
    else if (!abbr.isBlank) {
      return false
    }
    return true  // blank link, ok, just ignore it
  }

  func copyAbbreviationsToClipboard() {
    let text = Storage.keys.sorted().filter {
      it in it.matches("abbrev \\S+")
    }.map { it in it.replace("abbrev ","") + " " + Storage[it]!}
    let pb = UIPasteboard(name:.general,create:false)!
    pb.string = text.joined(separator:"\n")
  }

  func pasteAbbreviationsFromClipboard() {
    let pb = UIPasteboard(name:.general,create:false)!
    if (pb.string != nil) {
      let s = pb.string!
      s.split("\n").forEach { line in
        let words = line.split(" ",maxSplits: 2)
        if (words.count > 1) {
          addOneAbbreviation(words[0], words[1])
        }
      }
    }
    loadAbbreviations()
  }

}
