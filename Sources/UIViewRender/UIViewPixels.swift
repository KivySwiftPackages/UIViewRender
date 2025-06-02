

import PythonCore
import PySwiftCore
import PySerializing
import PyUnpack
import Foundation
import UIKit

fileprivate extension UnsafeMutablePointer<Int> {
	init(_ value: Int) {
		self = .allocate(capacity: 1)
		self.pointee = value
	}
}
fileprivate extension UnsafeMutablePointer<CChar> {
	static let ubyte_format: Self = makeCString(from: "B")
}

fileprivate extension Int {
	var stride: UnsafeMutablePointer<Int> {
		let _stride = UnsafeMutablePointer<Int>.allocate(capacity: 1)
		_stride.pointee = self
		return _stride
	}
}

fileprivate let element_size = MemoryLayout<UInt8>.size

public final class UIViewPixels {
	let data: UnsafeMutablePointer<UInt8>
	let capacity: Int
	
	init(capacity: Int) {
		self.data = .new(capacity)
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

extension UIViewPixels: PySerialize {
	public var pyPointer: PyPointer {
		Self.asPyPointer(self)
	}
}


extension UIViewPixels: UIViewPixels_PyProtocol {
	
	// will be called when UIViewPixels object is used as arg input in texture.blit_buffer
	static var PyBuffer: PyBufferProcs = .init(
		bf_getbuffer: { s, buffer, rw in
			guard let buffer = buffer else {
				PyErr_SetString(PyExc_MemoryError, "UIViewPixels has no buffer")
				return -1
			}
			let cls: UIViewPixels = UnPackPyPointer(from: s)
			let size = cls.capacity
			buffer.pointee.buf = .init(cls.data)
			
			buffer.pointee.len = size
			buffer.pointee.readonly = 0
			buffer.pointee.itemsize = element_size
			buffer.pointee.format = .ubyte_format
			buffer.pointee.ndim = 1
			buffer.pointee.shape = size.stride
			buffer.pointee.strides = element_size.stride
			
			buffer.pointee.suboffsets = nil
			buffer.pointee.internal = nil

			return 0
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






