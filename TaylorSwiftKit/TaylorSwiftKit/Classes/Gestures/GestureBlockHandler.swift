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
	
	private var handlers = [UIView: dispatch_block_t]()
	
	public func addSingleTapToView(view: UIView, onTap: dispatch_block_t) -> UITapGestureRecognizer {
		let gesture = UITapGestureRecognizer(target: self, action: "handleGesture:")
		gesture.numberOfTapsRequired = 1
		handlers[view] = onTap
		view.addGestureRecognizer(gesture)
		view.userInteractionEnabled = true
		return gesture
	}	
	
	// MARK: Gesture Handling
	
	func handleGesture(gesture: UIGestureRecognizer) {
		if let view = gesture.view, handler = handlers[view] {
			handler()
		}
	}
	
}