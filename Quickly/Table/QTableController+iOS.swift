//
//  Quickly
//

#if os(iOS)

    open class QTableController: NSObject, IQTableController, IQTableCellDelegate, IQTableDecorDelegate {

        public weak var tableView: UITableView? = nil {
            didSet {
                self.configure()
            }
        }
        public var sections: [IQTableSection] = []
        public var rows: [IQTableRow] {
            get {
                return self.sections.flatMap({ (section: IQTableSection) -> [IQTableRow] in
                    return section.rows
                })
            }
        }
        public var canEdit: Bool = true
        public var canMove: Bool = true
        private var decors: [IQTableDecor.Type]
        private var cells: [IQTableCell.Type]

        public init(
            cells: [IQTableCell.Type]
        ) {
            self.decors = []
            self.cells = cells
            super.init()
        }

        public init(
            decors: [IQTableDecor.Type],
            cells: [IQTableCell.Type]
        ) {
            self.decors = decors
            self.cells = cells
            super.init()
        }

        fileprivate func decorClass(data: IQTableData) -> IQTableDecor.Type? {
            return self.decors.first(where: { (decor: IQTableDecor.Type) -> Bool in
                return decor.using(any: data)
            })
        }

        fileprivate func cellClass(row: IQTableRow) -> IQTableCell.Type? {
            return self.cells.first(where: { (cell: IQTableCell.Type) -> Bool in
                return cell.using(any: row)
            })
        }

        open func configure() {
            if let tableView: UITableView = self.tableView {
                for type: IQTableDecor.Type in self.decors {
                    type.register(tableView: tableView)
                }
                for type: IQTableCell.Type in self.cells {
                    type.register(tableView: tableView)
                }
                tableView.estimatedRowHeight = 44
                tableView.estimatedSectionHeaderHeight = 44
                tableView.estimatedSectionFooterHeight = 44
            }
            self.reload()
        }

        public func section(index: Int) -> IQTableSection {
            return self.sections[index]
        }

        public func index(section: IQTableSection) -> Int? {
            return self.sections.index { (existSection: IQTableSection) -> Bool in
                return existSection === section
            }
        }

        public func header(index: Int) -> IQTableData? {
            return self.sections[index].header
        }

        public func index(header: IQTableData) -> Int? {
            return self.sections.index(where: { (existSection: IQTableSection) -> Bool in
                return existSection.header === header
            })
        }

        public func footer(index: Int) -> IQTableData? {
            return self.sections[index].footer
        }

        public func index(footer: IQTableData) -> Int? {
            return self.sections.index(where: { (existSection: IQTableSection) -> Bool in
                return existSection.footer === footer
            })
        }

        public func row(indexPath: IndexPath) -> IQTableRow {
            return self.sections[indexPath.section].rows[indexPath.row]
        }

        public func row(predicate: (IQTableRow) -> Bool) -> IQTableRow? {
            for section: IQTableSection in self.sections {
                for row: IQTableRow in section.rows {
                    if predicate(row) {
                        return row
                    }
                }
            }
            return nil
        }

        public func indexPath(row: IQTableRow) -> IndexPath? {
            var sectionIndex: Int = 0
            for existSection: IQTableSection in self.sections {
                var cellIndex: Int = 0
                for existRow: IQTableRow in existSection.rows {
                    if existRow === row {
                        return IndexPath(row: cellIndex, section: sectionIndex)
                    }
                    cellIndex += 1
                }
                sectionIndex += 1
            }
            return nil
        }

        public func indexPath(predicate: (IQTableRow) -> Bool) -> IndexPath? {
            var sectionIndex: Int = 0
            for existSection: IQTableSection in self.sections {
                var cellIndex: Int = 0
                for existRow: IQTableRow in existSection.rows {
                    if predicate(existRow) {
                        return IndexPath(row: cellIndex, section: sectionIndex)
                    }
                    cellIndex += 1
                }
                sectionIndex += 1
            }
            return nil
        }

        public func header(data: IQTableData) -> IQTableDecor? {
            guard let tableView: UITableView = self.tableView else {
                return nil
            }
            guard let index: Int = self.index(header: data) else {
                return nil
            }
            return tableView.headerView(forSection: index) as? IQTableDecor
        }

        public func footer(data: IQTableData) -> IQTableDecor? {
            guard let tableView: UITableView = self.tableView else {
                return nil
            }
            guard let index: Int = self.index(footer: data) else {
                return nil
            }
            return tableView.footerView(forSection: index) as? IQTableDecor
        }

        public func cell(row: IQTableRow) -> IQTableCell? {
            guard let tableView: UITableView = self.tableView else {
                return nil
            }
            guard let indexPath: IndexPath = self.indexPath(row: row) else {
                return nil
            }
            return tableView.cellForRow(at: indexPath) as? IQTableCell
        }

        public func dequeue(data: IQTableData) -> IQTableDecor? {
            guard let tableView: UITableView = self.tableView else {
                return nil
            }
            guard let decorClass: IQTableDecor.Type = self.decorClass(data: data) else {
                return nil
            }
            return decorClass.dequeue(tableView: tableView) as? IQTableDecor
        }

        public func dequeue(row: IQTableRow, indexPath: IndexPath) -> IQTableCell? {
            guard let tableView: UITableView = self.tableView else {
                return nil
            }
            guard let cellClass: IQTableCell.Type = self.cellClass(row: row) else {
                return nil
            }
            return cellClass.dequeue(tableView: tableView, indexPath: indexPath) as? IQTableCell
        }

        public func reload() {
            guard let tableView: UITableView = self.tableView else {
                return
            }
            tableView.reloadData()
        }

        public func beginUpdates() {
            guard let tableView: UITableView = self.tableView else {
                return
            }
            tableView.beginUpdates()
        }

        public func endUpdates() {
            guard let tableView: UITableView = self.tableView else {
                return
            }
            tableView.endUpdates()
        }

        public func scroll(row: IQTableRow, scroll: UITableViewScrollPosition, animated: Bool) {
            guard let tableView: UITableView = self.tableView else {
                return
            }
            guard let indexPath: IndexPath = self.indexPath(row: row) else {
                return
            }
            tableView.scrollToRow(at: indexPath, at: scroll, animated: animated)
        }

        public func isSelected(row: IQTableRow) -> Bool {
            guard let tableView: UITableView = self.tableView else {
                return false
            }
            guard let selectedIndexPaths: [IndexPath] = tableView.indexPathsForSelectedRows else {
                return false
            }
            if let indexPath: IndexPath = self.indexPath(row: row) {
                return selectedIndexPaths.contains(indexPath)
            }
            return false
        }

        public func select(row: IQTableRow, scroll: UITableViewScrollPosition, animated: Bool) {
            guard let tableView: UITableView = self.tableView else {
                return
            }
            guard let indexPath: IndexPath = self.indexPath(row: row) else {
                return
            }
            tableView.selectRow(at: indexPath, animated: animated, scrollPosition: scroll)
        }

        public func deselect(row: IQTableRow, animated: Bool) {
            guard let tableView: UITableView = self.tableView else {
                return
            }
            guard let indexPath: IndexPath = self.indexPath(row: row) else {
                return
            }
            tableView.deselectRow(at: indexPath, animated: animated)
        }

        public func update(header: IQTableData) {
            guard let tableView: UITableView = self.tableView else {
                return
            }
            guard let index: Int = self.index(header: header) else {
                return
            }
            guard let decorView: IQTableDecor = tableView.headerView(forSection: index) as? IQTableDecor else {
                return
            }
            decorView.update(any: header)
        }

        public func update(footer: IQTableData) {
            guard let tableView: UITableView = self.tableView else {
                return
            }
            guard let index: Int = self.index(footer: footer) else {
                return
            }
            guard let decorView: IQTableDecor = tableView.footerView(forSection: index) as? IQTableDecor else {
                return
            }
            decorView.update(any: footer)
        }

        public func update(row: IQTableRow) {
            guard let tableView: UITableView = self.tableView else {
                return
            }
            guard let indexPath: IndexPath = self.indexPath(row: row) else {
                return
            }
            guard let cell: IQTableCell = tableView.cellForRow(at: indexPath) as? IQTableCell else {
                return
            }
            cell.update(any: row)
        }

    }

    extension QTableController: UITableViewDataSource {

        public func numberOfSections(
            in tableView: UITableView
        ) -> Int {
            return self.sections.count
        }

        public func tableView(
            _ tableView: UITableView,
            numberOfRowsInSection index: Int
        ) -> Int {
            let section: IQTableSection = self.section(index: index)
            if section.hidden == true {
                return 0
            }
            return section.rows.count
        }

        public func tableView(
            _ tableView: UITableView,
            cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell {
            let row: IQTableRow = self.row(indexPath: indexPath)
            let cell: IQTableCell? = self.dequeue(row: row, indexPath: indexPath)
            cell?.tableDelegate = self
            cell?.set(any: row)
            return cell as! UITableViewCell
        }

        public func tableView(
            _ tableView: UITableView,
            canEditRowAt indexPath: IndexPath
        ) -> Bool {
            let section: IQTableSection = self.section(index: indexPath.section)
            if section.canEdit == false {
                return false;
            }
            let row: IQTableRow = section.rows[indexPath.row]
            return row.canEdit;
        }

        public func tableView(
            _ tableView: UITableView,
            canMoveRowAt indexPath: IndexPath
        ) -> Bool {
            let section: IQTableSection = self.section(index: indexPath.section)
            if section.canMove == false {
                return false;
            }
            let row: IQTableRow = section.rows[indexPath.row]
            return row.canMove;
        }

    }

    extension QTableController: UITableViewDelegate {

        public func tableView(
            _ tableView: UITableView,
            heightForRowAt indexPath: IndexPath
        ) -> CGFloat {
            let row: IQTableRow = self.row(indexPath: indexPath)
            if let cellClass = self.cellClass(row: row) {
                return cellClass.height(any: row, width: tableView.frame.size.width)
            }
            return 0
        }

        public func tableView(
            _ tableView: UITableView,
            heightForHeaderInSection section: Int
        ) -> CGFloat {
            if let data: IQTableData = self.header(index: section) {
                if let decorClass: IQTableDecor.Type = self.decorClass(data: data) {
                    return decorClass.height(any: data, width: tableView.frame.size.width)
                }
            }
            return 0
        }

        public func tableView(
            _ tableView: UITableView,
            heightForFooterInSection section: Int
        ) -> CGFloat {
            if let data: IQTableData = self.footer(index: section) {
                if let decorClass: IQTableDecor.Type = self.decorClass(data: data) {
                    return decorClass.height(any: data, width: tableView.frame.size.width)
                }
            }
            return 0
        }

        public func tableView(
            _ tableView: UITableView,
            viewForHeaderInSection section: Int
        ) -> UIView? {
            if let data: IQTableData = self.header(index: section) {
                if let decorClass: IQTableDecor.Type = self.decorClass(data: data) {
                    let view = decorClass.dequeue(tableView: tableView)
                    if let decorView: IQTableDecor = view as? IQTableDecor {
                        decorView.tableDelegate = self
                        decorView.set(any: data)
                    }
                    return view
                }
            }
            return nil
        }

        public func tableView(
            _ tableView: UITableView,
            viewForFooterInSection section: Int
        ) -> UIView? {
            if let data: IQTableData = self.footer(index: section) {
                if let decorClass: IQTableDecor.Type = self.decorClass(data: data) {
                    let view = decorClass.dequeue(tableView: tableView)
                    if let decorView: IQTableDecor = view as? IQTableDecor {
                        decorView.tableDelegate = self
                        decorView.set(any: data)
                    }
                    return view
                }
            }
            return nil
        }

        public func tableView(
            _ tableView: UITableView,
            shouldHighlightRowAt indexPath: IndexPath
        ) -> Bool {
            let row: IQTableRow = self.row(indexPath: indexPath)
            return row.canSelect
        }

        public func tableView(
            _ tableView: UITableView,
            willSelectRowAt indexPath: IndexPath
        ) -> IndexPath? {
            let row: IQTableRow = self.row(indexPath: indexPath)
            if row.canSelect == false {
                return nil
            }
            return indexPath
        }

        public func tableView(
            _ tableView: UITableView,
            willDeselectRowAt indexPath: IndexPath
        ) -> IndexPath? {
            let row: IQTableRow = self.row(indexPath: indexPath)
            if row.canSelect == false {
                return nil
            }
            return indexPath
        }

        public func tableView(
            _ tableView: UITableView,
            editingStyleForRowAt indexPath: IndexPath
        ) -> UITableViewCellEditingStyle {
            let row: IQTableRow = self.row(indexPath: indexPath)
            return row.editingStyle
        }

    }

#endif
