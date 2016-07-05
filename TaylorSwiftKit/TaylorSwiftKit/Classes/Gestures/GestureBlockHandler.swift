//
//  GestureBlockHandler.swift
//  TaylorSwiftKit
//
//  Created by David Casserly on 23/01/2016.
//  Copyright © 2016 DevedUpLtd. All rights reserved.
//

import Foundation
import UIKit

@objc public class GestureBlockHandler: NSObject {
	
	private var handlers = [UIView: () -> ()]()
	
	public func addSingleTapToView(_ view: UIView, onTap: () -> ()) -> UITapGestureRecognizer {
		let gesture = UITapGestureRecognizer(target: self, action: #selector(GestureBlockHandler.handleGesture(_:)))
		gesture.numberOfTapsRequired = 1
		handlers[view] = onTap
		view.addGestureRecognizer(gesture)
		view.isUserInteractionEnabled = true
		return gesture
	}	
	
	// MARK: Gesture Handling
	
	func handleGesture(_ gesture: UIGestureRecognizer) {
		if let view = gesture.view, handler = handlers[view] {
			handler()
		}
	}
	
}
