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
  }

}
