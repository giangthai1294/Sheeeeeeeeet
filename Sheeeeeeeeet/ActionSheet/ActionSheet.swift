//
//  ActionSheet.swift
//  Sheeeeeeeeet
//
//  Created by Daniel Saidi on 2017-11-26.
//  Copyright © 2017 Daniel Saidi. All rights reserved.
//

/*
 
 This is the main class in the Sheeeeeeeeet library. You can
 use it to create action sheets and present them in any view
 controller, from any source view or bar button item.
 
 To create an action sheet, just call the initializer with a
 list of items and buttons and a block that should be called
 whenever an item is selected.
 
 
 ## Items
 
 You provide an action sheet with a collection of items when
 you create it. The sheet will automatically split the items
 into items and buttons. You can also create an action sheet
 with an empty item collection, then call `setup(items:)` at
 a later time. This is sometimes required if you must create
 the action sheet before you can create the items.
 
 
 ## Presentation
 
 You can inject a custom presenter if you want to change how
 the sheet is presented and dismissed. The default presenter
 is `ActionSheetDefaultPresenter`. It uses action sheets for
 iPhone devices and popovers for iPad devices.
 
 
 ## Subclassing
 
 `ActionSheet` can be subclassed, which may be nice whenever
 you want to use your own domain model. For instance, if you
 want to present a list of `Food` items, you should create a
 `FoodActionSheet` sheet, then populate it with `Food` items.
 The selected value will then be of the type `Food`. You can
 either override the initializers or the `setup` function to
 change how you populate the sheet with items.
 
 
 ## Appearance
 
 Sheeeeeeeeet's action sheet appearance if easily customized.
 To change the global appearance for every sheet in your app,
 just modify `ActionSheetAppearance.standard`. To change the
 appearance of a single action sheet, modify the `appearance`
 property. To change the appearance of a single item, modify
 its `customAppearance` property.
 
 
 ## Triggered actions
 
 `ActionSheet` has two actions that are triggered by tapping
 an item. `itemTapAction` is used by the sheet itself when a
 tap occurs on an item. You can override this if you want to,
 but you probably shouldn't. `itemSelectAction`, however, is
 the main select action. You must provide it when you create
 an action sheet, so it can never be nil.
 
 */

import UIKit

open class ActionSheet: UIViewController {
    
    
    // MARK: - Initialization
    
    public init(
        items: [ActionSheetItem],
        presenter: ActionSheetPresenter = ActionSheet.defaultPresenter,
        action: @escaping SelectAction) {
        self.presenter = presenter
        selectAction = action
        super.init(nibName: ActionSheet.className, bundle: Bundle(for: ActionSheet.self))
        setup(items: items)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        presenter = ActionSheet.defaultPresenter
        selectAction = { _, _ in print("itemSelectAction is not set") }
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit { print("\(type(of: self)) deinit") }
    
    
    // MARK: - Setup
    
    open func setup() {}
    
    open func setup(items: [ActionSheetItem]) {
        self.items = items.filter { !($0 is ActionSheetButton) }
        buttons = items.compactMap { $0 as? ActionSheetButton }
        reloadData()
    }
    
    @available(*, deprecated, message: "setupItemsAndButtons(with:) is deprecated. Use setup(items:) instead")
    open func setupItemsAndButtons(with items: [ActionSheetItem]) {
        setup(items: items)
    }
    
    
    // MARK: - View Controller Lifecycle
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refresh()
    }
    
    
    // MARK: - Typealiases
    
    public typealias SelectAction = (ActionSheet, ActionSheetItem) -> ()
    
    public typealias TapAction = (ActionSheetItem) -> ()
    
    
    // MARK: - Dependencies
    
    open var appearance = ActionSheetAppearance(copy: .standard)
    
    open var presenter: ActionSheetPresenter
    
    
    // MARK: - Actions
    
    open var selectAction: SelectAction
    
    open lazy var tapAction: TapAction = { [weak self] item in
        self?.handleTap(on: item)
    }
    
    @available(*, deprecated, message: "itemSelectAction is deprecated. Use selectAction instead")
    open var itemSelectAction: SelectAction { return selectAction }
    
    @available(*, deprecated, message: "itemTapAction is deprecated. Use tapAction instead")
    open var itemTapAction: TapAction { return tapAction }
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var topMargin: NSLayoutConstraint?
    @IBOutlet weak var leftMargin: NSLayoutConstraint?
    @IBOutlet weak var rightMargin: NSLayoutConstraint?
    @IBOutlet weak var bottomMargin: NSLayoutConstraint?
    
    @IBOutlet weak var backgroundView: UIView?
    @IBOutlet weak var stackView: UIStackView?
    
    @IBOutlet weak var headerViewContainer: UIView? {
        didSet { headerViewContainer?.backgroundColor = .clear }
    }
    
    @IBOutlet weak var itemsTableView: UITableView? {
        didSet { setup(itemsTableView, with: itemHandler) }
    }
    
    @IBOutlet weak var itemsTableViewHeight: NSLayoutConstraint?
    
    @IBOutlet weak var buttonsTableView: IntrinsicTableView? {
        didSet { setup(buttonsTableView, with: buttonHandler) }
    }
    
    @IBOutlet weak var buttonsTableViewHeight: NSLayoutConstraint?
    
    
    // MARK: - Header
    
    open var headerView: UIView? {
        didSet { refresh() }
    }
    
    
    // MARK: - Items
    
    open var items = [ActionSheetItem]()
    
    open var itemsHeight: CGFloat { return totalHeight(for: items) }
    
    open lazy var itemHandler = ActionSheetItemHandler(actionSheet: self, handles: .items)
    
    
    // MARK: - Buttons
    
    open var buttons = [ActionSheetButton]()
    
    open var buttonsHeight: CGFloat { return totalHeight(for: buttons) }
    
    open lazy var buttonHandler = ActionSheetItemHandler(actionSheet: self, handles: .buttons)
    
    
    // MARK: - Presentation Functions
    
    open func dismiss(completion: @escaping () -> () = {}) {
        presenter.dismiss { completion() }
    }

    open func present(in vc: UIViewController, from view: UIView?, completion: @escaping () -> () = {}) {
        refresh()
        presenter.present(sheet: self, in: vc.rootViewController, from: view, completion: completion)
    }

    open func present(in vc: UIViewController, from barButtonItem: UIBarButtonItem, completion: @escaping () -> () = {}) {
        refresh()
        presenter.present(sheet: self, in: vc.rootViewController, from: barButtonItem, completion: completion)
    }

    open func refresh() {
        applyRoundCorners()
        items.forEach { $0.applyAppearance(appearance) }
        itemsTableView?.separatorColor = appearance.itemsSeparatorColor
        itemsTableViewHeight?.constant = itemsHeight
        buttons.forEach { $0.applyAppearance(appearance) }
        buttonsTableView?.separatorColor = appearance.itemsSeparatorColor
        buttonsTableViewHeight?.constant = buttonsHeight
        presenter.refreshActionSheet()
    }
    
    
    // MARK: - Public Functions
    
    open func margin(at margin: ActionSheetMargin) -> CGFloat {
        let minimum = appearance.contentInset
        return margin.value(in: view.superview, minimum: minimum)
    }

    open func item(at indexPath: IndexPath) -> ActionSheetItem {
        return items[indexPath.row]
    }

    open func reloadData() {
        itemsTableView?.reloadData()
        buttonsTableView?.reloadData()
    }
}


// MARK: - Private Functions

private extension ActionSheet {
    
    func applyRoundCorners() {
        applyRoundCorners(to: headerViewContainer)
        applyRoundCorners(to: itemsTableView)
        applyRoundCorners(to: buttonsTableView)
    }

    func applyRoundCorners(to view: UIView?) {
        view?.clipsToBounds = true
        view?.layer.cornerRadius = appearance.cornerRadius
    }
    
    func setup(_ view: UITableView?, with handler: ActionSheetItemHandler) {
        view?.tableFooterView = UIView.empty
        view?.cellLayoutMarginsFollowReadableWidth = false
        view?.rowHeight = UITableView.automaticDimension
        view?.estimatedRowHeight = 44
        view?.dataSource = handler
        view?.delegate = handler
    }
    
    func totalHeight(for items: [ActionSheetItem]) -> CGFloat {
        return items.reduce(0) { $0 + $1.appearance.height }
    }

    func handleTap(on item: ActionSheetItem) {
        reloadData()
        guard item.tapBehavior == .dismiss else { return selectAction(self, item) }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.dismiss { self.selectAction(self, item) }
        }
    }
}
