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

class Setting {

  static let settings = UserDefaults.standard

  private let name:String
  init(_ name:String) {
    self.name = name
  }

  var s:String? {
    get { return Setting.settings.string(forKey: name) }
    set { Setting.settings.set(newValue, forKey: name) }
  }

  var b:Bool? {
    //  UserDefaults returns false if key not set, so we need to test to find the difference
    get { return Setting.settings.object(forKey: name) != nil ? Setting.settings.bool(forKey: name) : nil }
    set { Setting.settings.set(newValue, forKey: name) }
  }

}
