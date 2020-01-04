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

class CachingLinearLayout : ViewGroup {

  private let mydiv:UITableView
  private var indexed = false
  private var sections:[[View]] = [[]]
  private var sectionIndex:[String] = []
  private var currentIndex = ""

  init(indexed:Bool = false) {
    self.indexed = indexed
    mydiv = UITableView(frame: .zero, style: .plain)
    mydiv.translatesAutoresizingMaskIntoConstraints = false
    super.init(mydiv)
    let bgview = UIView()
    bgview.backgroundColor = UIColor.lightGray
    mydiv.backgroundView = bgview
    mydiv.dataSource = self
    mydiv.delegate = self
    mydiv.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    mydiv.allowsSelection = false
  }

  @discardableResult
  override func appendView(_ child: View) -> View {
    children.append(child)
    if (indexed) {
      let textView = (child as! ViewGroup).findChildThat { v in v is TextView } as! TextView
      var tc = textView.text.replaceAll("\\W","").first!.uppercased()
      if (!tc.matches("[A-Z]")) {
        tc = "#"
      }
      if (tc != currentIndex) {
        sections.append([])
        sectionIndex.append(tc)
        currentIndex = tc
      }
      sections[sections.count-1].append(child)
    } else {
      sections[0].append(child)
    }
    invalidate()
    return child
  }

  override func clear() {
    children = []
    sections = [[]]
    sectionIndex = []
    currentIndex = ""
    invalidate()
  }

  override func invalidate() {
    mydiv.reloadData()
  }

}

extension CachingLinearLayout: UITableViewDataSource {

  public func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }

  public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    return sectionIndex
  }

  public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
    return index
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sections[section].count
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    NSLayoutConstraint.deactivate(cell.contentView.constraints)
    cell.contentView.subviews.forEach { $0.removeFromSuperview() }
    let child = sections[indexPath.section][indexPath.row]
    cell.contentView.addSubview(child.div)
    cell.contentView.backgroundColor = child.backgroundColor
    child.fillParent()
    return cell
  }

}

extension CachingLinearLayout: UITableViewDelegate {

  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let maxsize = CGSize(width: div.bounds.width, height: CGFloat.greatestFiniteMagnitude)
    let mysize = sections[indexPath.section][indexPath.row].div.sizeThatFits(maxsize)
    return mysize.height + 6
  }

  public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    return indexPath
  }
}