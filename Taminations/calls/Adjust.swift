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

class Adjust : Action {

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    let fname = name.replaceIgnoreCase("adust to (a(n)?)?", "")
    var formation: XMLElement
    if (norm.matches(".*line(s)?")) {
      formation = TamUtils.getFormation("Normal Lines")
    }
    else if (norm.matches(".*thar")) {
      formation = TamUtils.getFormation("Thar RH Boys")
    }
    else if (norm.matches(".*square(d)?set")) {
      formation = TamUtils.getFormation("Squared Set")
    }
    else if (norm.matches(".*boxes")) {
      formation = TamUtils.getFormation("Eight Chain Thru")
    }
    else if (norm.matches(".*14tag")) {
      formation = TamUtils.getFormation("Quarter Tag")
    }
    else if (norm.matches(".*diamonds")) {
      formation = TamUtils.getFormation("Diamonds RH Girl Points")
    }
    else if (norm.matches(".*tidal(wave|line)?")) {
      formation = TamUtils.getFormation("Tidal Line RH")
    }
    else if (norm.matches(".*hourglass")) {
      formation = TamUtils.getFormation("Hourglass RH BP")
    }
    else if (norm.matches(".*galaxy")) {
      formation = TamUtils.getFormation("Galaxy RH GP")
    }
    else if (norm.matches(".*butterfly")) {
      formation = TamUtils.getFormation("Butterfly RH")
    }
    else if (norm.matches(".*o")) {
      formation = TamUtils.getFormation("O RH")
    }
    else {
      throw CallError("Sorry, don't know how to \(name) from here.")
    }
    let ctx2 = CallContext(formation)
    guard let mapping = ctx.matchFormations(ctx2,sexy:false,fuzzy:true,rotate:true,handholds:false, maxError:2.0) else {
      throw CallError("Unable to match formation to \(fname)")
    }
    let matchResult = ctx.computeFormationOffsets(ctx2,mapping,delta:0.3)
    let match = CallContext.BestMapping(name:fname,mapping:mapping,offsets:matchResult.offsets,totOffset:0.0)
    ctx.adjustToFormationMatch(match)
  }

}
