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

class LinearLayout : ViewGroup {

  enum Direction {
    case HORIZONTAL
    case VERTICAL
  }

  class LinearLayoutView : UIView {
    let dir:Direction
    init( _ dir:Direction) {
      self.dir = dir
      super.init(frame: .zero)
      translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
      var mysize = size
      mysize.width = 0
      mysize.height = 0
      subviews.forEach { child in
        let childsize = child.sizeThatFits(size)
        if (dir == .VERTICAL) {
          mysize.width = max(mysize.width,childsize.width)
          mysize.height += childsize.height
        } else {
          mysize.width += childsize.width
          mysize.height = max(mysize.height,childsize.height)
        }
      }
      return mysize
    }

  }

  private let mydiv:LinearLayoutView
  let dir:Direction

  init(_ div:LinearLayoutView) {
    self.dir = div.dir
    mydiv = div
    super.init(mydiv)
  }

  init(_ dir:Direction) {
    self.dir = dir
    mydiv = LinearLayoutView(dir)
    super.init(mydiv)
  }

  convenience init(_ frame:CGRect, _ dir:Direction) {
    self.init(dir)
    mydiv.frame = frame
  }

  func setSize(_ child1:View, _ child2:View, _ ratio:Double) {
    let attr = dir == .HORIZONTAL ? NSLayoutConstraint.Attribute.width : NSLayoutConstraint.Attribute.height
    NSLayoutConstraint(item: child1.div, attribute: attr, relatedBy: .equal,
        toItem: child2.div, attribute: attr, multiplier: ratio.cg, constant: 0).isActive = true
  }

  override func layoutChildren() {
    super.layoutChildren()
    NSLayoutConstraint.deactivate(div.constraints)
    //  Layout children in given direction
    let visChildren = children //.filter {!$0.div.isHidden }
    let firstWeightedView:View? = visChildren.first { $0.weight > 0 }
    for (i,child) in visChildren.enumerated() {
      if (dir == Direction.VERTICAL) {
        if (i == 0) {
          //  First child - align to parent
          alignEdge(child,.top,self,.top)
        } else {
          //  Middle child - align to back of previous child
          alignEdge(child,.top,visChildren[i-1],.bottom)
        }
        //  If last child and we are filling the parent, align to end of parent
        if (i == visChildren.count-1 /* && hasWeight */ ) {
          alignEdge(child,.bottom,self,.bottom)
        }
      } else {  // HORIZONTAL
        if (i == 0) {
          //  First child
          alignEdge(child,.left,self,.left)
        } else {
          //  Middle child
          alignEdge(child,.left,visChildren[i-1],.right)
        }
        //  Last child
        if (i == visChildren.count-1 /* && hasWeight */ ) {
          alignEdge(child,.right,self,.right)
        }
      }

      //  width or height, in direction of layout
      if (child.weight > 0 && child !== firstWeightedView) {
        //  Weighted children are sized proportionally
        setSize(child,firstWeightedView!,child.weight.d/firstWeightedView!.weight.d)
      } else if (child.weight == 0 /* && hasWeight */ ) {
        //  Children with weight of 0 get their intrinsic size
        //  Special check (hack) for child LinearLayout in the same direction
        //  which already has constraints
        var isSubLayout = false
        if let childlayout = child as? LinearLayout {
          isSubLayout = childlayout.dir == dir
        }
        if (!isSubLayout) {
          var childsize = CGSize(width: child.width, height: child.height)
          if (childsize.width == 0 && childsize.height == 0) {
            childsize = child.div.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
          }
          let sizer = dir == Direction.HORIZONTAL
            ? NSLayoutConstraint.Attribute.width
            : NSLayoutConstraint.Attribute.height
     //     child.div.sizeToFit()
          childsize = child.div.sizeThatFits(CGSize.zero)
          let mysize = child.div.isHidden ? 0 :
            dir == Direction.HORIZONTAL ? childsize.width : childsize.height
            NSLayoutConstraint(item: child.div, attribute: sizer, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.cg,
                  constant: mysize).isActive = true
        }
      }
      //  width or height in other direction
      if (dir == .VERTICAL) {
        if (child.align & Align.Left != 0) {
          alignEdge(child,.left,self,.left)
        }
        if (child.align & Align.Right != 0) {
          alignEdge(child,.right,self,.right)
        }
        if (child.align & Align.Middle != 0) {
          alignMiddle(child)
        }
      }
      if (dir == .HORIZONTAL) {
        if (child.align & Align.Top != 0) {
          alignEdge(child,.top,self,.top)
        }
        if (child.align & Align.Bottom != 0) {
          alignEdge(child,.bottom,self,.bottom)
        }
        if (child.align & Align.Center != 0) {
          alignCenter(child)
        }
        //  Set size of child if not filling
        //  But ViewGroup has constraints to size itself
        if (child.align & (Align.Top+Align.Bottom) != Align.Top+Align.Bottom &&
             !(child is ViewGroup)) {
          let childsize = child.div.sizeThatFits(CGSize.zero)
          NSLayoutConstraint(item: child.div, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.cg,
            constant: childsize.height).isActive = true
        }
      }
      child.invalidate()

    }
  }

}
