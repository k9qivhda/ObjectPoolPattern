//
//  Pool.swift
//  Test
//
//  Created by victor on 2017. 9. 18..
//  Copyright © 2017년 victor. All rights reserved.
//

import Foundation

class Pool<T> { // Generic type 'T'
    private var data = [T]() // Pool 내부에서만 접근 가능
    private let arrayQ = DispatchQueue(label: "arrayQ") //getFromPool 과 retrunToPool은 data array에 동시 접근 할 수 있는 race condition. 이를 해결하기 위해 하나의 쓰레드만 array에 접근하도록 동기화 시켜야함. iOS에서는 이를 위해 Serial 큐를 생성하여 별도의 단일 쓰레드에서 해당 Critical section을 처리하도록 한다.
    private let semaphore:DispatchSemaphore
    
    /* Pool 초기화 */
    init(items:[T]) {
        data.reserveCapacity(items.count) // items 갯수를 미리 알고 있으니 배열에 예약 메모리 할당을 막기 위해서( n = 2 * n) 미리 배열의 크기를 예약해 둠.
        for item in items {
            data.append(item); // data property에 전달 받은 items의 모든 원소를 저장
        }
        semaphore = DispatchSemaphore(value:items.count)
    }
    
    /* Pool check out */
    func getFromPool() -> T? { //Pool에 있는 객체를 꺼내옴. Optional인 이유는 모든 객체가 사용중이어서 Pool로 부터 가져오는 것이 실패할 경우 nil이 반환되므로
        var result:T?
        if(semaphore.wait(timeout: .distantFuture) == .success) {//Pool의 객체의 개수로 체크하면 오동작 할 수 있다. 세마포어로 변경하여 자원의 개수가 있는 경우에만 접근 가능하도록 변경
            //if(data.count > 0) { // Pool에 남아 있는 원소 체크
            arrayQ.sync { // 이 부분이 async가 된다면 해당 작업이 Queue에서 꺼내져서 완료될 때까지 기다리지 않고 바로 다음 실행 문으로 이동하게 되니까 nil이 반환될 것이다. 그러므로 이 부분은 꼭 Sync로 처리하기
                result = self.data.remove(at: 0) // 첫 번째 원소를 삭제하면서 삭제된 원소를 가져옴
            }
        }
        return result // nil 이거나 T이거나 둘 중 하나
    }
    
    /* Pool check in */
    func returnToPool(item:T) { //다 쓰고 반환할 때
        arrayQ.async {
            self.data.append(item)
            self.semaphore.signal()
        }
    }
}
