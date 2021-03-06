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

class XMLCall : Call {

  private var _name: String
  override var name: String { get { _name } }


  let xelem:XMLElement
  public let xmlmap:[Int]
  public let ctx2:CallContext
  init(_ xelem:XMLElement, _ xmlmap:[Int], _ ctx2:CallContext) {
    self.xelem = xelem
    self.xmlmap = xmlmap
    self.ctx2 = ctx2
    _name = xelem.attr("title")!
  }

  override func performCall(_ ctx: CallContext, _ index: Int) throws {
    //  TODO handle case where xelem is a xref
    let allp = xelem.children(tag:"path").map { Path(TamUtils.translatePath($0)) }
    //  If moving just some of the dancers,
    //  see if we can keep them in the same shape
    if (ctx.actives.count < ctx.dancers.count) {
      //  No animations have been done on ctx2,
      //  so dancers are still at the start points
      let ctx3 = CallContext(ctx2)
      //  So ctx3 is a copy of the start point
      //  Now add the paths
      ctx3.dancers.enumerated().forEach { (i,d) in
        d.path.add(allp[i >> 1])
      }
      //  And move it to the end point
      ctx3.extendPaths()
      ctx3.analyze()
    }

    let matchResult = ctx.computeFormationOffsets(ctx2,xmlmap,delta:0.2)
    xmlmap.enumerated().forEach { (i3,m) in
      let p = Path(allp[m>>1])
      if (p.movelist.isEmpty) {
        p.add(TamUtils.getMove("Stand"))
      }
      //  Scale active dancers to fit the space they are in
      //  Compute difference between current formation and XML formation
      let vd = matchResult.offsets[i3].rotate(-ctx.actives[i3].tx.angle)
      //  Apply formation difference to first movement of XML path
      if (vd.length > 0.1) {
        p.skewFirst(-vd.x,-vd.y)
      }
      //  Add XML path to dancer
      ctx.actives[i3].path.add(p)
      //  Move dancer to end so any subsequent modifications (e.g. roll)
      //  use the new position
      ctx.actives[i3].animateToEnd()
    }

    //  Mark dancers that had no XML move as inactive
    //  Needed for post-call modifications e.g. spread
    var inactives:[Dancer] = []
    xmlmap.enumerated().forEach { (i4,m) in
      if (allp[m>>1].movelist.count == 0) {
        inactives.append(ctx.actives[i4])
      }
    }
    inactives.forEach  { d in d.data.active = false }

    ctx.analyze()
  }

}
