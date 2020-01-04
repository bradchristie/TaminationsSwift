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
    "dx": "Dixie Style : a Wave",
    "ht": "Half Tag",
    "ptc": "Pass : the Center",
    "sb": "Scoot Back",
    "stt": "Spin the Top",
    "ttl": "Tag the Line",
    "wad": "Walk and Dodge"
  ]

  init(_ view:AbbreviationsView) {
    self.view = view
    //  Initialize with abbrevs above if 1st time
    if (Storage["+abbrev stored"] == nil) {
      initialAbbrev.forEach { (key,value) in
        Storage["abbrev \(key)"] = value
      }
      Storage["+abbrev stored"] = "true"
    }
  }

  func loadAbbreviations() {
    //  Read stored abbreviations and fill table
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
      //  error if duplicate
      if (Storage["abbrev " + view[i].abbr] != nil) {
        view.markError(i)
      }
      //  error if a word used in calls
      else if (TamUtils.words.contains(view[i].abbr.lowercased())) {
        view.markError(i)
      }
      //  ok if a single non-blank string
      else if (view[i].abbr.matches("\\S+") && !view[i].expa.isBlank) {
        Storage["abbrev " + view[i].abbr] = view[i].expa
      }
      //  otherwise (embedded spaces) error
      else if (!view[i].abbr.isBlank) {
        view.markError(i)
      }
    }
    //  Be sure we have a blank row at the bottom
    //  for adding a new abbreviation
    if (!view[view.numItems-1].abbr.isBlank) {
      view.addItem("", "")
    }
  }

}
