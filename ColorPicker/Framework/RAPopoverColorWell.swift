import Cocoa

@objc public protocol RAPopoverColorWellDelegate {
    func colorWell(_ colorWell: RAPopoverColorWell, didChangeColor color: NSColor)
}

@objc(RAPopoverColorWell)
public class RAPopoverColorWell: NSColorWell {
    private static let colorKeyPath = "color"
    private let viewController = RAColorPanelViewController()

    @IBOutlet
    @objc(delegate)
    public weak var delegate: RAPopoverColorWellDelegate?
    
    @objc
    override open var isEnabled: Bool {
        didSet {
            alphaValue = isEnabled ? 1 : 0.5
        }
    }
    
    override open func activate(_ exclusive: Bool) {
        viewController.loadView()
        viewController.colorPanel.color = color
        
        presentInPopover()
        
        viewController.colorPanel.addObserver(self,
                                              forKeyPath: Self.colorKeyPath,
                                              options: .new,
                                              context: nil)
    }
    
    open func presentInPopover() {
        let popover = NSPopover()
        
        popover.delegate = self
        popover.behavior = .semitransient
        popover.contentViewController = viewController
        popover.show(relativeTo: frame, of: self.superview!, preferredEdge: .maxX)
    }

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case Self.colorKeyPath:
            guard let panel = object as? NSColorPanel,
                    panel == viewController.colorPanel else {
                return
            }
            
            color = viewController.colorPanel.color
            
            delegate?.colorWell(self, didChangeColor: color)
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

extension RAPopoverColorWell: NSPopoverDelegate {
    public func popoverDidClose(_ notification: Notification) {
        deactivate()
        viewController.colorPanel.removeObserver(self, forKeyPath: Self.colorKeyPath)
    }
}
