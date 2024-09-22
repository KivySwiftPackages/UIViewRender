

import PythonCore
import PySwiftCore
import PyEncode
import PyUnpack

import Foundation
import UIKit


public final class UIViewPixels {
	let data: UnsafeMutablePointer<UInt8>
	let capacity: Int
	
	init(capacity: Int) {
		self.data = .allocate(capacity: capacity)
		self.data.initialize(repeating: 0, count: capacity)
		self.capacity = capacity
	}
	
	deinit {
		data.deallocate()
	}
}


extension UnsafeMutablePointer where Pointee == UInt8 {
	
	static func new(_ capacity: Int) -> Self {
		let ptr = Self.allocate(capacity: capacity)
		ptr.initialize(repeating: 0, count: capacity)
		return ptr
	}
}

extension UIViewPixels: PyEncodable {
	public var pyPointer: PyPointer {
		Self.asPyPointer(self)
	}
}


extension UIViewPixels: UIViewPixels_PyProtocol {
	
	// will be called when UIViewPixels object is used as arg input in texture.blit_buffer
	static var PyBuffer: PyBufferProcs = .init(
		bf_getbuffer: { s, buffer, rw in
			let cls: UIViewPixels = UnPackPyPointer(from: s)
			return PyBuffer_FillInfo(
				buffer,
				s,
				cls.data,
				cls.capacity,
				0,
				rw
			)
		},
		bf_releasebuffer: nil
	)
	
	public func __len__() -> Int {
		capacity
	}
	
	public func __add__(_ other: PythonCore.PyPointer?) -> PythonCore.PyPointer? {
		fatalError()
	}
	
	public func __mul__(_ n: Int) -> PythonCore.PyPointer? {
		fatalError()
	}
	
	// return list data of pixel at x/y
	public func __getitem__(_ i: Int) -> PythonCore.PyPointer? {
		return [
			data[i],
			data[i + 1],
			data[i + 2],
			data[i + 3]
		].pyPointer
	}
	
	public func __getitem__alt(_ i: Int) -> PythonCore.PyPointer? {
		let list = PyList_New(4)!
		list.append(data[0]) // append extension to PyObject ptr :-) ofc only use it if object is a list
		list.append(data[i + 1])
		list.append(data[i + 2])
		list.append(data[i + 3])
		return list
	}
	
	public func __setitem__(_ i: Int, _ item: PythonCore.PyPointer?) -> Int32 {
		fatalError()
	}
	
	public func __contains__(_ item: PythonCore.PyPointer?) -> Int32 {
		fatalError()
	}
	
	public func __iadd__(_ item: PythonCore.PyPointer?) -> PythonCore.PyPointer? {
		fatalError()
	}
	
	public func __imul__(_ n: Int) -> PythonCore.PyPointer? {
		fatalError()
	}
	
	public static func __fill_buffer__(AnyObject src: UIViewPixels, buffer: UnsafeMutablePointer<Py_buffer>) -> Int32 {
		fatalError()
	}
}






