//
//  DataManager.swift
//  simpleMemo
//
//  Created by hhj on 2022/04/04.
//

import Foundation
import CoreData

class DataManager {
    static let shared = DataManager()
    // 앱 전체에서 하나의 인스턴스를 공유 Singleton
    private init() {
        
    }
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var memoList = [Memo]()
    
    // 메모 목록 데이터 fetch
    func fetchMemo() {
        let request: NSFetchRequest<Memo> = Memo.fetchRequest()
        let sortByDateDesc = NSSortDescriptor(key: "insertDate", ascending: false) // 날짜를 기준으로 내림차순 정렬
        
        request.sortDescriptors = [sortByDateDesc]
        
        do {
            memoList = try mainContext.fetch(request)
        } catch {
           print(error)
        }
    }
    
    // 새로운 메모 추가
    func addNewMemo(_ memo: String?) {
        let newMemo = Memo(context: mainContext)
        newMemo.content = memo
        newMemo.insertDate = Date()
        
        // 메모리스트 배열 첫번째에 새로운 메모 추가
        memoList.insert(newMemo, at: 0)
        
        saveContext()
    }
    
    // 메모 삭제
    func deleteMemo(_ memo: Memo?) {
        if let memo = memo {
            // context 가 제공하는 delete 메소드를 호출 한 뒤에 저장
            mainContext.delete(memo)
            saveContext()
        }
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "simpleMemo")
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved Error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK - Core Data Saving Support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved Error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
