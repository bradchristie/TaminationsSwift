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

class Finish : Action {

  override var level: LevelData { LevelObject.find("c1") }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    let finishCall = name.replaceIgnoreCase("Finish\\s+", " ")
    let finishNorm = TamUtils.normalizeCall(finishCall)
    //  For now we just work with XML calls
    //  Find matching XML call
    let files = ctx.xmlFilesForCall(finishNorm)
    let found = files.any { link in
      CallContext.loadedXML[link]?.xpath("/tamination/tam").filter { tam in
        tam.attr("sequencer") != "no" &&
          TamUtils.normalizeCall(tam.attr("title")!) == finishNorm
      }.first { tam in
        //  Should be divided into parts, will also accept fractions
        let parts = (tam.attr("parts") ?? "") + (tam.attr("fractions") ?? "")
        let allp = tam.children(tag: "path").map {
          Path(TamUtils.translatePath($0))
        }
        guard let firstPart = parts.split(";").first?.d else { return false }
        //  Load the call and animate past the first part
        let ctx2 = CallContext(tam, loadPaths: true)
        ctx2.animate(firstPart)
        guard let mapping = ctx.matchFormations(ctx2) else { return false }
        let matchResult = ctx.computeFormationOffsets(ctx2, mapping)
        ctx.adjustToFormationMatch(matchResult)
        mapping.enumerated().forEach { i, m in
          let p = Path(allp[m >> 1])
          var firstBeats = 0.0
          while (firstBeats.isLessThan(firstPart)) {
            firstBeats += p.shift()?.beats ?? firstPart
          }
          ctx.dancers[i].path.add(p)
        }
        return true
      } != nil
    }
    if (!found) {
      throw CallError("Could not figure out how to Finish \(finishCall)")
    }
  }

}
