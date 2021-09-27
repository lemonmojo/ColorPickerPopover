import Cocoa

internal protocol RAColorPanelViewControllerDelegate: AnyObject {
	func colorPanelViewController(_ viewController: RAColorPanelViewController, didChangeColor color: NSColor)
}

internal class RAColorPanelViewController: NSViewController {
	weak var delegate: RAColorPanelViewControllerDelegate?
	
	private var isObserving = false
	private let colorKeyPath = (\NSColorPanel.color)._kvcKeyPathString ?? "color"
	
	private var colorPanel: NSColorPanel { .shared }
	private var colorView: NSView?
	
	var showsAlpha: Bool {
		get { colorPanel.showsAlpha }
		set { colorPanel.showsAlpha = newValue }
	}
	
	var mode: NSColorPanel.Mode {
		get { colorPanel.mode }
		set { colorPanel.mode = newValue }
	}
	
	var color: NSColor {
		get { colorPanel.color }
		set { colorPanel.color = newValue }
	}
	
	var alpha: CGFloat {
		colorPanel.alpha
	}
	
	deinit {
		unembedColorPanel()
	}
    
    override func loadView() {
		if !isViewLoaded {
			view = NSView()
		}
		
		guard let colorView = colorPanel.contentView else { return }
		
		view.frame = colorView.bounds
    }
	
	override func viewWillAppear() {
		embedColorPanel()
	}
	
	override func viewWillDisappear() {
		unembedColorPanel()
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		switch keyPath {
		case colorKeyPath:
			guard let panel = object as? NSColorPanel,
				  panel == colorPanel else {
				return
			}
			
			delegate?.colorPanelViewController(self, didChangeColor: color)
		default:
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
		}
	}
}

extension RAColorPanelViewController {
	func unembedColorPanel() {
		stopObservingColor()
		
		if let colorView = colorView {
			colorView.removeFromSuperview()
			colorPanel.contentView = colorView
			self.colorView = nil
		}
	}
}

private extension RAColorPanelViewController {
	func embedColorPanel() {
		if NSColorPanel.sharedColorPanelExists && colorPanel.isVisible {
			colorPanel.orderOut(self)
		}
		
		guard let colorView = colorPanel.contentView else {
			self.colorView = nil
			
			return
		}
		
		view.addSubview(colorView)
		
		self.colorView = colorView
		
		if let swatch = locateColorSwatch() {
			swatch.perform(NSSelectorFromString("updateSwatch"))
		}
		
//        if let toolbar = colorPanel.toolbar {
//            NSLog("%i", toolbar.items.count)
//
//            let item = toolbar.items[1]
//
//            if let icon = item.image {
//                print("\(icon.size)")
//            }
//        }
		
		startObservingColor()
	}
	
	func startObservingColor() {
		colorPanel.addObserver(self,
							   forKeyPath: colorKeyPath,
							   options: .new,
							   context: nil)
		
		isObserving = true
	}
	
	func stopObservingColor() {
		guard isObserving else { return }
		
		colorPanel.removeObserver(self,
								  forKeyPath: colorKeyPath)
		
		isObserving = false
	}
	
    func locateColorSwatch() -> NSView? {
		guard let rootView = colorPanel.contentView else { return nil }
		
		return findSwatchInSubviews(v: rootView)
    }
    
    func findSwatchInSubviews(v: NSView) -> NSView? {
        let classNameToLocate = "NSColorSwatch"
        
        for subview in v.subviews {
            if subview.className == classNameToLocate {
                return subview
            } else if let foundView = findSwatchInSubviews(v: subview) {
                return foundView
            }
        }
        
        return nil
    }
}
