//
//  Quickly
//

import UIKit

public protocol IQTableController: UITableViewDataSource, UITableViewDelegate {

    weak var tableView: UITableView? { set get }
    var sections: [ITableSection] { set get }
    var canEdit: Bool { get }
    var canMove: Bool { get }

    func configure()

    func section(index: Int) -> ITableSection
    func index(section: ITableSection) -> Int?

    func header(index: Int) -> IQTableData?
    func index(header: IQTableData) -> Int?

    func footer(index: Int) -> IQTableData?
    func index(footer: IQTableData) -> Int?

    func row(indexPath: IndexPath) -> IQTableRow
    func row(predicate: (IQTableRow) -> Bool) -> IQTableRow?

    func indexPath(row: IQTableRow) -> IndexPath?
    func indexPath(predicate: (IQTableRow) -> Bool) -> IndexPath?

    func dequeue(data: IQTableData) -> IQTableDecor?
    func dequeue(row: IQTableRow) -> IQTableCell?

    func reload()

    func beginUpdates()
    func endUpdates()

    func isSelected(row: IQTableRow) -> Bool
    func select(row: IQTableRow, scroll: UITableViewScrollPosition, animated: Bool)
    func deselect(row: IQTableRow, animated: Bool)

    func update(header: IQTableData)
    func update(footer: IQTableData)
    func update(row: IQTableRow)

}