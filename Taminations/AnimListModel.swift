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

enum CellType {
  case Header
  case Separator
  case Indented
  case Plain
}

class AnimListItem {
  let celltype: CellType
  let title:String
  let name:String
  let group:String
  let animnumber:Int
  var fullname = ""
  var view:SelectablePanel? = nil
  var isItemSelected = false
  var wasItemSelected = false
  init(celltype:CellType,title:String,name:String,group:String,animnumber:Int = -1) {
    self.celltype = celltype
    self.title = title
    self.name = name
    self.group = group
    self.animnumber = animnumber
  }
}


class AnimListModel {

  private var animListItems:[AnimListItem] = []
  private var selectanim:SelectablePanel?
  private var alview:AnimListView
  var link:String

  init(_ alview:AnimListView, _ request:Request) {
    self.alview = alview
    link = request["link"]!
    let doc = TamUtils.getXMLAsset(link)
    let tams = doc.xpath("/tamination/*[@title]")
    Application.app.titleBar.title = doc.xpath("/tamination").first!.attr("title")!
    let level = link.split("/").first!
    Application.app.titleBar.level = LevelObject.find(level).name
    // Fetch the list of animations and build the table
    var prevtitle = ""
    var prevgroup = ""
    if (tams.filter { it in !(it.attr("display") ?? "").startsWith("n")
    }.any { tam in (tam.attr("difficulty") ?? "0") != "0" }) {
      alview.keyView.show()
    } else {
      alview.keyView.hide()
    }
    tams.filter { it in
      !(it.attr("display") ?? "").startsWith("n")
    }.forEach { tam in
      let tamtitle = tam.attr("title")!
      var from = "from"
      let group = tam.attr("group") ?? ""
      if (!group.isEmpty) {
        // Add header for new group as needed
        if (group != prevgroup) {
          if (group.isBlank) {
            // Blank group, for calls with no common starting phrase
            // Add a separator unless it's the first group
            if (alview.count > 0) {
              addSeparator(AnimListItem(celltype:.Separator, title:"", name:"", group:""))
            }
          } else {
            // Named group e.g. "As Couples.."
            // Add a header with the group name, which starts
            // each call in the group
            addSeparator(AnimListItem(celltype:.Header, title:"", name:group, group:""))
          }
        }
        from = tamtitle.replace(group, " ").trim()
      } else if (tamtitle != prevtitle) {
        // Not a group but a different call
        // Put out a header with this call
        addSeparator(AnimListItem(celltype:.Header, title:"", name:"\(tamtitle) from", group:""))
      }
      //  Build list item for this animation
      prevtitle = tamtitle
      prevgroup = group
      // Put out a selectable item
      let i = animListItems.count
      if (group.isBlank && !group.isEmpty) {
        addItem(tam, AnimListItem(celltype:.Plain, title:tamtitle, name:from, group:group, animnumber:i))
      } else if (!group.isEmpty) {
        addItem(tam, AnimListItem(celltype:.Indented, title:tamtitle, name:from, group:group, animnumber:i))
      } else {
        addItem(tam,AnimListItem(celltype:.Indented, title:tamtitle, name:from, group:"\(tamtitle) from", animnumber:i))
      }
    }
    alview.invalidate()
    Application.later {
      Application.app.sendMessage(Request(Request.Action.ANIMATION_READY, request))
    }
  }


  private func addSeparator(_ item:AnimListItem) {
    let v = LinearLayout(.HORIZONTAL)
    let tv = TextView(item.name)
    tv.textSize = 30.pp
    tv.wrap()
    tv.textColor = UIColor.white
    tv.leftMargin = 12
    v.appendView(tv)
    tv.fillVertical()
    alview.addItem(item,view:v)
  }

  private func addItem(_ tam:XMLElement, _ item:AnimListItem) {
    animListItems.append(item)
    let v = SelectablePanel()
    v.weight = 1
    alview.addItem(item,view:v)
    item.view = v
    if (item.animnumber >= 0) {
      v.clickAction {
        self.selectAnimation(item)
      }
    }
    let tamref = TamUtils.tamXref(tam)
    let difficulty = "0\(tamref.attr("difficulty") ?? "")".i
    if (item.celltype == .Separator || item.celltype == .Header) {
      v.backgroundColor = UIColor.SEPARATOR
    } else if (difficulty == 3) {
      v.backgroundColor = UIColor.EXPERT
    } else if (difficulty == 2) {
      v.backgroundColor = UIColor.HARDER
    } else if (difficulty == 1) {
      v.backgroundColor = UIColor.COMMON
    } else {
      v.backgroundColor = UIColor.white
    }
    //  select the first animation at start
    if (item.animnumber == 0) {
      v.isSelected = true
      selectanim = v
    }

    let tv = TextView(item.name=="from" ? tamref.attr("from")! : item.name)
    tv.textSize = 36.sp
    tv.wrap()
    tv.leftMargin = item.celltype == .Indented ? 30 : 12
    tv.topMargin = 4
    //tv.bottomMargin = 4
    tv.weight = 1
    tv.fillVertical()
    v.appendView(tv)

    if (item.name == "from") {
      item.fullname = item.title + " from " + tamref.attr("from")!
    } else if (!item.group.isBlank) {
      item.fullname = item.group + " " + item.name
    } else {
      item.fullname = item.name
    }

  }

  func selectFirstAnimation() {
    selectAnimation(animListItems.first { $0.animnumber >= 0 }!)
  }

  private func selectAnimation(_ item:AnimListItem) {
    selectanim?.isSelected = false
    selectanim = item.view
    item.view?.isSelected = true
    Application.app.sendMessage(.ANIMATION,
      ("link",link),("name",item.fullname),("title",item.title),("animnum","\(item.animnumber)"))
  }

}
