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

struct CallListData { let title:String, link:String }

class CallListModel {

  private let view:CallListView
  private var currentLevel = "b1"

  init(_ view:CallListView) {
    self.view = view
    view.searchInput.keyAction {
      self.reset(self.currentLevel,search:self.view.searchInput.text)
    }
  }

  func reset(_ level:String, search:String = "") {
    view.clearItems()
    currentLevel = level
    if (search.isEmpty) {
      // clear search box
      view.searchInput.text = ""
    }
    let d = LevelObject.find(level)
    let list = TamUtils.calldoc.xpath(d.selector)
    //  filter on search
    list.filter { it in search.isBlank || it.attr("title")!.lowercased().contains(search.lowercased()) }
      .forEach { it in
      view.addItem(CallListData(title: it.attr("title")!, link: it.attr("link")!))
    }
    view.invalidate()
  }

}
