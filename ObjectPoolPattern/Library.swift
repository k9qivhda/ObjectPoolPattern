//
//  Library.swift
//  Test
//
//  Created by victor on 2017. 9. 18..
//  Copyright © 2017년 victor. All rights reserved.
//

import Foundation

/*도서관*/
final class Library { // Library에서 책만 빌린다는 고정관념;; DVD도 빌릴 수 있고 강의실도 빌릴 수 있잖아.. 이 부분도 Generic Type 으로 만들 수 있을 것 같은데..
    private var books:[Book] // let으로 선언하고 싶은데 할 수가 없네... 굳이 Library의 멤버로 가지고 있을 필요가 있나? 어차피 Pool에 넣으면 객체가 복사될텐데...
    private let pool:Pool<Book>
    
    private init(stockLevel:Int) {
        books = [Book]()
        //        books = [Book](repeating: nil, count: stockLevel)
        for count in 1 ... stockLevel {
            books.append(Book(author: "Dickens, Charles", title: "Hard Times", stock: count))
        }
        pool = Pool<Book>(items:books)
    }
    
    private class var singleton:Library {
        struct SingletonWrapper {
            static let singleton = Library(stockLevel: 2)
        }
        return SingletonWrapper.singleton
    }
    
    class func checkoutBook(reader:String) -> Book? {
        var book = singleton.pool.getFromPool()
        book?.reader = reader
        book?.checkoutCount += 1
        return book
    }
    
    class func returnBook(book:Book) {
        book.reader = nil
        singleton.pool.returnToPool(item: book)
    }
    
    class func printReport() {
        for book in singleton.books {
            print("...Book#\(book.stockNumber)...")
            print("Checked out \(book.checkoutCount) times")
            if(book.reader != nil) {
                print("Checked out to \(book.reader!)")
            } else {
                print("In stock")
            }
        }
    }
}
