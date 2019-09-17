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

class Call {

  let _name:String
  var name:String { get { return _name } }
  var level:LevelData { return LevelObject.find("b1") }
  func performCall(_ ctx:CallContext, _ index:Int=0) throws { }
  func postProcess(_ ctx:CallContext, _ index:Int=0) {  }

  init(_ name:String) {
    self._name = name
  }

}
