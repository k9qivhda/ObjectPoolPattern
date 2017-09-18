//
//  main.swift
//  ObjectPoolPattern
//
//  Created by victor on 2017. 9. 18..
//  Copyright © 2017년 victor. All rights reserved.
//

import Foundation

var queue = DispatchQueue(label: "workQ", attributes: .concurrent)
var group = DispatchGroup()

print("Starting...")

for i in 1 ... 20 {
    queue.async(group: group, execute: {
        var book = Library.checkoutBook(reader: "reader#\(i)")
        if(book != nil) {
            Thread.sleep(forTimeInterval: Double(arc4random() % 2))
            Library.returnBook(book: book!)
        }
    })
}

group.wait(timeout: .distantFuture)
print("All blocks complete")
Library.printReport()


