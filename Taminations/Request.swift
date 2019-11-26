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

import Foundation

class Request : CustomStringConvertible {

  enum Action : String {
    //  Actions for page changes
    //  Some of these may also be sent as messages
    case NONE  // dummy value for no accepted actions
    case STARTUP
    case ABOUT
    case SETTINGS
    case SEQUENCER
    case STARTPRACTICE
    case TUTORIAL
    case PRACTICE
    case LEVEL
    case CALLLIST
    case CALLITEM
    case ANIMLIST
    case ANIMATION
    case DEFINITION
    case SEQUENCER_INSTRUCTIONS
    case SEQUENCER_CALLS
    case SEQUENCER_ABBREVIATIONS
    case SEQUENCER_SETTINGS

    //  Other messages
    case SETTINGS_CHANGED
    case ANIMATION_READY
    case ANIMATION_LOADED
    case ANIMATION_SELECTED
    case ANIMATION_PART
    case ANIMATION_PROGRESS
    case ANIMATION_DONE
    case SEQUENCER_LISTEN
    case SEQUENCER_READY
    case SEQUENCER_ERROR
    case SEQUENCER_CURRENTCALL
    case BUTTON_PRESS
    case SLIDER_CHANGE
    case TRANSITION_COMPLETE
    case TITLE
    case ABBREVIATIONS_CHANGED
    case RESOLUTION_ERROR
    case KEYBOARD_VISIBLE
    case REGENERATE
  }

  let action:Action
  private var params = Dictionary<String,String>()

  init(_ action:Action, _ pairs:[(String,String)]) {
    self.action = action
    for p in pairs {
      params[p.0] = p.1 == "delete" ? nil : p.1
    }
  }
  convenience init(_ action:Action, _ pairs:(String,String)...) {
    self.init(action,pairs)
  }

  //  Copy params from another request
  convenience init(_ action:Action, _ from:Request) {
    self.init(action)
    for (k,v) in from.params { params[k] = v }
  }

  //  Parse keys and values out of an URL
  convenience init(_ url:String) {
    var act = "STARTUP"
    var parms:[(String,String)] = []
    url.replace("#","").split("&").filter { !$0.isEmpty }.forEach { it in
      if (it.contains("=")) {
        let kv = it.split("=")
        let key = kv[0].decodeURI()
        let value = kv[1].decodeURI()
        if (key=="action") {
          act = value
        } else {
          parms.append((key,value))
        }
      }
    }
    self.init(Action(rawValue: act)!,parms)
  }

  subscript(key:String) -> String? {
    get { return params[key] }
    set { params[key] = newValue }
  }

  //  Convert keys and values back into a hash for an URL
  public var description:String {
    return (params.map { (key,value) in
      value.isEmpty ? key.encodeURI() : key.encodeURI()+"="+value.encodeURI()
    } + ["action=\(action)"]).joined(separator:"&")
  }

}

extension Request {
  var s:String { return "\(self)" }
}