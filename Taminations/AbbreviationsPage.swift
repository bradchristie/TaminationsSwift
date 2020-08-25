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

//  These are abbreviations used in the sequencer.
//  There is a standard list of abbreviations,
//  the user can add or delete to them.

class AbbreviationsPage : Page {

  private let _view = AbbreviationsView()
  override var view:View { return _view }
  let model:AbbreviationsModel

  override init() {
    model = AbbreviationsModel(_view)
    super.init()
    onAction(.SEQUENCER_ABBREVIATIONS) { request in
      self.model.loadAbbreviations()
    }
    onMessage(.ABBREVIATIONS_CHANGED) { request in
      self.model.saveAbbreviations()
    }
    onMessage(.BUTTON_PRESS) { request in
      if (request["id"] == "Abbrev Copy") {
        self.model.copyAbbreviationsToClipboard()
        Alert("Sequencer","Abbreviations copied to clipboard") { }
      }
      else if (request["id"] == "Abbrev Paste") {
        Alert("Sequencer","This will MERGE abbreviations from the clipboard. " +
          "If you want to REPLACE all your abbreviations, Clear first then Load.",
          cancel:true) {
          self.model.pasteAbbreviationsFromClipboard()
        }
      }
      else if (request["id"] == "Abbrev Clear") {
        Alert("Sequencer","WARNING! This will ERASE ALL your abbreviations!",cancel: true) {
          self.model.clearAbbreviations()
        }
      }
      else if (request["id"] == "Abbrev Reset") {
        Alert("Sequencer","WARNING! This will REPLACE ALL your abbreviations!",cancel: true) {
          self.model.defaultAbbreviations()
        }
      }
    }
  }

}
