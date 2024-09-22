import UIKit
import PySwiftCore
import PythonCore
import PyUnpack

import KivyTexture

let uiScale = UIScreen.main.scale

extension UIView {
	
	public func pixels() -> UIViewPixels {
		let wh = layer.frame.size
		let width = Int(wh.width * uiScale)
		let height = Int(wh.height * uiScale)
		return render2pixels(width: width, height: height, scale: uiScale)
	}
	
	public func render2pixels(width: Int, height: Int, scale: Double) -> UIViewPixels {

		let bytesPerRow = width * 4
		let size = bytesPerRow * height
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		
		let pixels = UIViewPixels(capacity: size)
		
		let context = CGContext(
			data: pixels.data,
			width: width,
			height: height,
			bitsPerComponent: 8,
			bytesPerRow: bytesPerRow,
			space: colorSpace,
			bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
		)!
		context.scaleBy(x: scale, y: scale)
		layer.render(in: context)
		
		return pixels
	}
}


extension UIView: KivyTextureProtocol {
	public func texture() -> PyPointer {
		let wh = layer.frame.size
		let width = Int(wh.width * uiScale)
		let height = Int(wh.height * uiScale)
		
		let pixels = render2pixels(width: width, height: height, scale: uiScale).pyPointer
		let tex = KivyTexture(pixels: pixels, width: width, height: height)
		pixels.decref()
		return tex.data
	}
}
