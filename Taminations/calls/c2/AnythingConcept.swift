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


class AnythingConcept : Action {

  override var level: LevelData { LevelObject.find("c2") }

  override var requires:[String] { [
    "a2/split_counter_rotate","c1/counter_rotate",
    "b1/circulate","a1/cross_over_circulate",
    "a2/in_roll_circulate","a2/out_roll_circulate",
    "a2/trade_circulate",
    "c2/split_trade_circulate",
    "c3a/scatter_circulate" ]
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    var firstCall = norm.replaceIgnoreCase("(.*)(motivate|coordinate|percolate|perkup)", "$1")
    let secondCall = norm.replaceIgnoreCase("(.*)(motivate|coordinate|percolate|perkup)", "$2")
    //  If the first call is Counter Rotate or Split Counter Rotate
    //  the word Rotate is generally omitted
    if (firstCall.matches("(split)?counter")) {
      firstCall += "rotate"
    }
    //  If the first call is any type of Circulate
    //  the word Circulate is generally omitted
    else if (firstCall.matches("split|trade|splittrade|inroll|outroll|crossover|scatter")) {
      firstCall += "circulate"
    }
    try ctx.applyCalls(firstCall,"Finish \(secondCall)")
  }
}
