import Cocoa

@objc
public protocol RAPopoverColorWellDelegate {
	@objc(colorWell:didChangeColor:)
    func colorWell(_ colorWell: RAPopoverColorWell, didChangeColor color: NSColor)
}

@objc(RAPopoverColorWell)
public class RAPopoverColorWell: NSColorWell {
	private let colorPanelViewController = RAColorPanelViewController()

    @IBOutlet
    @objc(delegate)
    public weak var delegate: RAPopoverColorWellDelegate?
	
	private static var popoverColorWells = [RAPopoverColorWell]()
	
	deinit {
		Self.popoverColorWells.removeAll { colorWell in colorWell == self }
		
		colorPanelViewController.delegate = nil
	}
	
	public override func viewDidMoveToSuperview() {
		let added = superview != nil
		
		if added {
			Self.popoverColorWells.append(self)
		} else {
			Self.popoverColorWells.removeAll { colorWell in colorWell == self }
		}
	}
	
	@objc
    public override func activate(_ exclusive: Bool) {
		colorPanelViewController.delegate = nil
		
		let deactivateAllColorWellsSelector = NSSelectorFromString("_deactivateAllColorWells")
		
		if NSColorWell.responds(to: deactivateAllColorWellsSelector) {
			NSColorWell.perform(deactivateAllColorWellsSelector)
		}
		
		for colorWell in Self.popoverColorWells {
//			guard colorWell != self else { continue }
			
			colorWell.deactivate()
		}
		
		NSColorPanel.shared.orderOut(self)
		
		presentInPopover()
    }
	
	@objc
	public override func deactivate() {
		colorPanelViewController.delegate = nil
		colorPanelViewController.unembedColorPanel()
		
		super.deactivate()
	}
}

private extension RAPopoverColorWell {
	func presentInPopover() {
		colorPanelViewController.delegate = nil
		
		let popover = NSPopover()
		
		popover.delegate = self
		popover.behavior = .semitransient
		popover.contentViewController = colorPanelViewController
		
		popover.show(relativeTo: frame,
					 of: self.superview!,
					 preferredEdge: .maxX)
		
		colorPanelViewController.color = color
		colorPanelViewController.delegate = self
	}
}

extension RAPopoverColorWell: NSPopoverDelegate {
	public func popoverWillClose(_ notification: Notification) {
		deactivate()
	}
}

extension RAPopoverColorWell: RAColorPanelViewControllerDelegate {
	func colorPanelViewController(_ viewController: RAColorPanelViewController, didChangeColor color: NSColor) {
		self.color = color
		delegate?.colorWell(self, didChangeColor: color)
	}
}
