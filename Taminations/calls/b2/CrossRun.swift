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

class CrossRun : Action {

  override var level: LevelData { LevelObject.find("b2") }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    if (ctx.actives.count < ctx.dancers.count) {
      try super.perform(ctx,index)
      return
    }
    //  Get runners and dodgers
    let spec = name.replaceIgnoreCase("cross\\s*run", "")
    let specCtx = CallContext(ctx)
    try specCtx.applySpecifier(spec)
    let runners = ctx.actives.filter { specCtx.actives.contains($0) }
    let dodgers = ctx.actives.filter { !runners.contains($0) }
    //  Loop through runners and figure out where they are going
    try runners.forEach { d in
      //  find active dancer 2 dancers away it can run to
      let dright = ctx.dancersToRight(d).getOrNull(1)
      let dleft = ctx.dancersToLeft(d).getOrNull(1)
      let dir = dright?.data.active != true ? "Left" :
        dleft?.data.active != true ? "Right" :
        dright!.location.length > dleft!.location.length ? "Right": "Left"
      guard let d2 = dir == "Right" ? dright : dleft else {
        throw CallError("Dancer \(d) cannot Cross Run.")
      }
      let dist = d.distanceTo(d2)
      d.path.add(TamUtils.getMove("Run \(dir)").scale(1.5,dist/2.0))
    }
    //  Loop through each dodger and figure out which way they are moving
    try dodgers.forEach { d in
      //  Find a direction they can move to a runner's spot
      //  I don't think there can be more than one
      //  in a symmetric formation
      let dright = ctx.dancerToRight(d)
      let dleft = ctx.dancerToLeft(d)
      let dfront = ctx.dancerInFront(d)
      let dback = ctx.dancerInBack(d)
      //  Dodge or move to that spot
      if (dright != nil && runners.contains(dright!)) {
        d.path.add(TamUtils.getMove("Dodge Right")).scale(1.0,d.distanceTo(dright!)/2.0)
      } else if (dleft != nil && runners.contains(dleft!)) {
        d.path.add(TamUtils.getMove("Dodge Left")).scale(1.0,d.distanceTo(dleft!)/2.0)
      } else if (dfront != nil && runners.contains(dfront!)) {
        d.path.add(TamUtils.getMove("Forward")).changebeats(3.0).scale(d.distanceTo(dfront!),1.0)
      } else if (dback != nil && runners.contains(dback!)) {
        d.path.add(TamUtils.getMove("Back")).changebeats(3.0).scale(d.distanceTo(dback!),1.0)
      } else {
        throw CallError("Unable to calculate Cross Run action for dancer \(d)")
      }
    }

  }

}