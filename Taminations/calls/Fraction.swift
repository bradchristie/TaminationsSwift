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


class Fraction: Action {

  private var prevbeats = 0.0
  private var partbeats = 0.0
  private var call:Call = Nothing()

  private var numerator = 0
  private var denominator = 0

  override func perform(_ ctx: CallContext, _ i: Int) throws {
    numerator = String(norm.first!).i
    denominator = String(norm.last!).i
    if (i+1 < ctx.callstack.count) {
      //  Steal the next call off the stack
      call = ctx.callstack[i + 1]
      //  For XML calls there should be an explicit number of parts
      if (call is XMLCall) {
        //  Figure out how many beats are in the fractional call
        let parts = (call as! XMLCall).xelem.attr("parts") ??
                    (call as! XMLCall).xelem.attr("fractions") ?? ""
        if (parts.isNotEmpty()) {
          let partnums = parts.split(";")
          let numParts = partnums.count + 1
          if (numParts % denominator != 0) {
            throw CallError("Unable to divide \(call.name) into \(denominator) parts.")
          }
          if (numerator < 1 || numerator >= denominator) {
            throw CallError("Invalid fraction.")
          }
          let partsToDo = numParts * numerator / denominator
          partbeats = partnums[0..<partsToDo].reduce(0, { (n,s) in n + Double(s)! } )
        }
      }
      prevbeats = ctx.maxBeats
    } else {
      throw CallError("\(name) of what?")
    }
  }

  //  Call is performed between these two methods

  override func postProcess(_ ctx: CallContext, _ i: Int) {
    //  Coded calls so far do not have explicit parts
    //  so just divide them by the given fraction
    //  Also if an XML call does not have parts just divide the beats
    if (call is Action || partbeats == 0.0) {
      partbeats = (ctx.maxBeats - prevbeats) * numerator.d / denominator.d
    }

    //  Chop off the excess fraction
    ctx.dancers.forEach { d in
      var moq: Movement? = nil
      while (d.path.beats > prevbeats + partbeats) {
        moq = d.path.pop()
      }
      //  OK if there's no movement, part of nothing is nothing
      if let mo = moq {
        if (d.path.beats < prevbeats + partbeats) {
          d.path.add(mo.clip(prevbeats + partbeats - d.path.beats))
        }
      }
    }

    super.postProcess(ctx, i)
  }
}

