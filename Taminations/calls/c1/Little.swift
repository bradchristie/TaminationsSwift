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

class Little : Action {

  override var level: LevelData { LevelObject.find("c1") }
  override var requires:[String] { ["b1/face","c1/counter_rotate","c1/step_and_fold","ms/scoot_back"] }

  override func perform(_ ctx: CallContext, _ index: Int) throws {

    //  Do the Scoot Back of Scoot and Little
    if (norm.startsWith("scootand")) {
      try ctx.applyCalls("Scoot Back")
    }
    let norm2 = norm.replace("scootand", "")

    //  Figure out which way the outside dancers turn
    var turn = "Face Right"
    if (norm2.startsWith("left") || norm2.endsWith("left")) {
      turn = "Face Left"
    }
    else if (norm2.startsWith("right") || norm2.endsWith("right")) {
      turn = "Face Right"
    }
    else if (norm2.startsWith("in") || norm2.endsWith("in")) {
      turn = "Face In"
    }
    else if (norm2.startsWith("out") || norm2.endsWith("out")) {
      turn = "Face Out"
    }
    else if (norm2.endsWith("forward") || norm2.endsWith("asyouare")) {
      turn = ""
    }
    do {
      if (ctx.actives.count == 8) {
        try ctx.applyCalls("Outer 4 \(turn) Counter Rotate While Center 4 Step and Fold")
      } else if (ctx.actives.count == 4 && ctx.actives.containsAll(ctx.outer(4))) {
        try ctx.applyCalls("Outer 4 \(turn) Counter Rotate")
      } else {
        throw CallError("Don't know how to Little for these dancers.")
      }
    } catch _ as CallError {
    throw CallError("Unable to do Little from this formation.")
  }

  }
}
