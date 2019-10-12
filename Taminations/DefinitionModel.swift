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

class DefinitionModel {

  private let dv:DefinitionView
  private var currentLink = ""
  private var currentCall = ""

  init(_ dv:DefinitionView) {
    self.dv = dv
    dv.abbrevRB.clickAction {
      dv.eval("setAbbrev(true)")
      Setting("DefinitionAbbrev").b = true
    }
    dv.fullRB.clickAction {
      dv.eval("setAbbrev(false)")
      Setting("DefinitionAbbrev").b = false
    }
  }

  func setDefinition(link:String,title:String) {
    if (link != currentLink) {
      var langlink = link
      //  See if we have it in the user's language
      var lang = Locale.preferredLanguages[0].replaceAll("[-_].*", "")
      switch (Setting("Language for Definitions").s) {
        case "English" : lang = "en"
        case "German" : lang = "de"
        case "Japanese" : lang = "ja"
        default : ()
      }
      if (lang != "en" && TamUtils.calldata.first { it in
          link == it.link && it.languages.contains(lang) } != nil) {
        langlink += ".lang-\(lang)"
      }
      dv.setSource(langlink, afterload: {
        let isAbbrev = Setting("DefinitionAbbrev").b == true
        if (isAbbrev) {
          self.dv.abbrevRB.isChecked = true
        } else {
          self.dv.fullRB.isChecked = true
        }
        self.dv.eval("setAbbrev(\(isAbbrev))") { result in
          if (result == "false") {
            self.dv.buttonView.hide()
          } else {
            self.dv.buttonView.show()
          }
        }
      })
    }
    if (!title.isEmpty) {
      currentCall = title.replaceAll(" ","")
    }
  }

  //  This is needed for highlighting definitions that contain several calls
  //  such as Swing Thru and Left Swing Thru
  func setTitle(_ title:String) {
    currentCall = title.replaceAll(" ","")
  }

  func setPart(_ part:Int) {
    dv.eval("setPart(\(part),'\(currentCall)')")
  }

}
