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

import UIKit

class MultiColumnLayout : ViewGroup {

  private let mydiv:UICollectionView
  private let layout = UICollectionViewFlowLayout()


  init() {
    mydiv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    layout.scrollDirection = .horizontal
    layout.itemSize = CGSize(width: 300, height: 30)
    layout.minimumInteritemSpacing = 1.cg
    layout.minimumLineSpacing = 1.cg
    super.init(mydiv)
    mydiv.translatesAutoresizingMaskIntoConstraints = false
    mydiv.setCollectionViewLayout(layout, animated: false)
    mydiv.dataSource = self
    mydiv.delegate = self
    mydiv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    backgroundColor = UIColor.lightGray
  }

  @discardableResult
  override func appendView(_ child: View) -> View {
    children.append(child)
    invalidate()
    return child
  }

  override func removeView(_ child: View) {
    //  not used
  }

  override func clear() {
    children = []
    invalidate()
  }

  override func invalidate() {
    mydiv.reloadData()
  }
}

extension MultiColumnLayout: UICollectionViewDataSource {

  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  public func collectionView(_ collectionView: UICollectionView,
                             numberOfItemsInSection section: Int) -> Int {
    return children.count
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
    NSLayoutConstraint.deactivate(cell.contentView.constraints)
    cell.contentView.subviews.forEach { $0.removeFromSuperview() }
    let child = children[indexPath.row]
    cell.contentView.addSubview(child.div)
    cell.contentView.backgroundColor = child.backgroundColor
    //cell.contentView.bounds = CGRect(x: 0, y: 0, width: 200, height: 30)
    //children[indexPath.row].fillParent()
    return cell
  }

}

extension MultiColumnLayout: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let maxsize = CGSize(width: 300, height: CGFloat.greatestFiniteMagnitude)
    var mysize = children[indexPath.row].div.sizeThatFits(maxsize)
    mysize.width = 300
    return mysize
  }
}