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

struct LevelData : Comparable, Equatable {
  let name:String
  let dir:String
  let color:UIColor
  let selector:String

  static func < (lhs:LevelData, rhs:LevelData) -> Bool {
    let lhi = LevelObject.data.firstIndex(of:lhs)!
    let rhi = LevelObject.data.firstIndex(of:rhs)!
    return lhi < rhi
  }

  static func == (lhs:LevelData, rhs:LevelData) -> Bool {
    return lhs.dir == rhs.dir
  }

}

class LevelObject {

  static fileprivate let data = [LevelData(name:"Basic and Mainstream", dir:"bms", color: UIColor.BMS, selector:"/calls/call[starts-with(@link,'b') or starts-with(@link,'ms')]"),
                             LevelData(name:"Basic 1", dir:"b1", color:UIColor.B1, selector: "/calls/call[starts-with(@link,'b1')]"),
                             LevelData(name:"Basic 2", dir:"b2", color:UIColor.B2, selector: "/calls/call[starts-with(@link,'b2')]"),
                             LevelData(name:"Mainstream", dir:"ms", color:UIColor.B2, selector: "/calls/call[starts-with(@link,'ms')]"),
                             LevelData(name:"Plus", dir:"plus", color:UIColor.PLUS, selector: "/calls/call[starts-with(@link,'plus')]"),
                             LevelData(name:"Advanced", dir:"adv", color:UIColor.ADV, selector: "/calls/call[starts-with(@link,'a')]"),
                             LevelData(name:"A-1", dir:"a1", color:UIColor.A1, selector: "/calls/call[starts-with(@link,'a1')]"),
                             LevelData(name:"A-2", dir:"a2", color:UIColor.A2, selector: "/calls/call[starts-with(@link,'a2')]"),
                             LevelData(name:"Challenge", dir:"cha", color:UIColor.CHALLENGE, selector: "/calls/call[starts-with(@link,'c')]"),
                             LevelData(name:"C-1", dir:"c1", color:UIColor.C1, selector: "/calls/call[starts-with(@link,'c1')]"),
                             LevelData(name:"C-2", dir:"c2", color:UIColor.C2, selector: "/calls/call[starts-with(@link,'c2')]"),
                             LevelData(name:"C-3A", dir:"c3a", color:UIColor.C3A, selector: "/calls/call[starts-with(@link,'c3a')]"),
                             LevelData(name:"C-3B", dir:"c3b", color:UIColor.C3B, selector: "/calls/call[starts-with(@link,'c3b')]"),
                             LevelData(name: "All Calls", dir: "all", color: UIColor.lightGray, selector: "/calls/call"),
                             LevelData(name: "Index of All Calls", dir: "all", color: UIColor.lightGray, selector: "/calls/call")
]

  class func find(_ s:String) -> LevelData {
    //  following lets us easily find the level of a link
    return data.first { s.startsWith($0.dir) || $0.name == s }!
  }

}
