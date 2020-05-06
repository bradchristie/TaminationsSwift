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

class ModifiedFormationConcept : Action {

  var conceptName:String { "" }
  var realCall:String { name.replaceIgnoreCase("\(conceptName) ", "") }
  var formationName:String { "" }
  var modifiedFormationName:String { "" }

  func checkFormation(_ ctx:CallContext) -> Bool {
    let ctx2 = CallContext(TamUtils.getFormation(formationName))
    return ctx.matchFormations(ctx2,sexy:false,fuzzy:true,rotate:90,handholds:false) != nil
  }

  func reformFormation(_ ctx:CallContext) -> Bool {
    ctx.adjustToFormation(formationName,rotate:180) ||
    ctx.adjustToFormation(formationName,rotate:90)
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  Check that the formation matches
    if (!checkFormation(ctx)) {
      throw CallError("Not $conceptName formation")
    }
    //  Shift dancers into modified formation
    if (!ctx.adjustToFormation(modifiedFormationName,rotate:180) &&
        !ctx.adjustToFormation(modifiedFormationName,rotate:180)) {
      throw CallError("Unable to adjust \(formationName) to \(modifiedFormationName)")
    }
    let adjusted = ctx.dancers.filter { $0.path.movelist.isNotEmpty() }

    //  Perform the call
    let callName = name.replaceFirstIgnoreCase(conceptName, "")
    try ctx.applyCalls(callName)
    //  Merge the initial adjustment into the start of the call
    ctx.dancers.forEach { d in
      if (adjusted.contains(d) && d.path.movelist.count > 1) {
        let dy = d.path.movelist.first!.btranslate.endPoint.y
        d.path.shift()
        d.path.skewFirst(0.0,dy)
      }
    }

    //  Reform the formation
    if (!reformFormation(ctx)) {
      throw CallError("Unable to reform $formationName formation")
    }
  }
}
