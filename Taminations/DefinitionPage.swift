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

class DefinitionPage : Page {

  private let _view = DefinitionView()
  override var view:View { get { return _view } }
  private let model:DefinitionModel

  override init() {
    model = DefinitionModel(_view)
    super.init()
    onAction(.DEFINITION) { request in
      self.model.setDefinition(link: request["link"]!, title: request["title"] ?? "")
    }
    onMessage(.ANIMATION) { request in
      self.model.setTitle(request["title"]!)
    }
    onMessage(Request.Action.ANIMATION_PART) { request in
      self.model.setPart(request["part"]!.i)
    }
  }

}
