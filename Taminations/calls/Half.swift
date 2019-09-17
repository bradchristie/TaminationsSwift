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


class Half : Action {

  var prevbeats = 0.0
  var halfbeats = 0.0
  var call:Call = Nothing()

  init() {
    super.init("Half")
  }

  override func perform(_ ctx: CallContext, _ i: Int) throws {
    if (i+1 < ctx.callstack.count) {
      //  Steal the next call off the stack
      call = ctx.callstack[i + 1]
      //  For XML calls there should be an explicit number of parts
      if (call is XMLCall) {
        //  Figure out how many beats are in half the call
        let parts = (call as! XMLCall).xelem.attr("parts") ?? ""
        if (parts.isNotEmpty()) {
          let partnums = parts.split(";")
          halfbeats = partnums[0..<partnums.count/2].reduce(0, { (n,s) in n + Double(s)! } )
        }
      }
      prevbeats = ctx.maxBeats
    } else {
      throw CallError("Half of what?")
    }
  }

  //  Call is performed between these two methods
  override func postProcess(_ ctx: CallContext, _ i: Int) {
    //  Coded calls so far do not have explicit parts
    //  so just divide them in two
    //  Also if an XML call does not have parts just divide beats in two
    if (call is Action || halfbeats == 0.0) {
      halfbeats = (ctx.maxBeats - prevbeats) / 2.0
    }

    //  Chop off the excess half
    ctx.dancers.forEach { d in
      var moq: Movement? = nil
      while (d.path.beats > prevbeats + halfbeats) {
        moq = d.path.pop()
      }
      //  OK if there's no movement, half of nothing is nothing
      if let mo = moq {
        if (d.path.beats < prevbeats + halfbeats) {
          d.path.add(mo.clip(prevbeats + halfbeats - d.path.beats))
        }
      }
    }

    super.postProcess(ctx, i)
  }
}

