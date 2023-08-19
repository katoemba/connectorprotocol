//
// ConnectorProtocol
//
// The MIT License (MIT)
//
// Copyright (c) 2018 Katoemba Software
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
	

import Foundation
import RxSwift

public protocol SectionIdentifiable {
    var id: String { get set }
    func filter(_ filter: String) -> Bool
}

public protocol ObjectSectionsProtocol {
    associatedtype objectType: SectionIdentifiable
    
    var numberOfSections: Int { get }
    func rowsInSection(_ section: Int) -> Int
    var sectionTitles: [String] { get }
    func getObjectObservable(indexPath: IndexPath) -> Observable<objectType>
    func filter(_ filter: String) -> ObjectSections<objectType>
}

public class ObjectSections<T: SectionIdentifiable>: ObjectSectionsProtocol {
    public typealias objectType = T

    private let sectionIndex = 0
    private let rowIndex = 1
    
    private class ObjectTuple {
        var loadStatus: LoadStatus
        var objectSubject: BehaviorSubject<objectType>
        var object: objectType
        
        init(loadStatus: LoadStatus, object: objectType) {
            self.loadStatus = loadStatus
            self.objectSubject = BehaviorSubject<objectType>(value: object)
            self.object = object
        }
    }
    
    private var objectTuples = [[ObjectTuple]]()
    private var _sectionTitles = [String]()
    public var sectionTitles: [String] {
        return _sectionTitles
    }
    
    private var bag = DisposeBag()
    
    public var numberOfSections: Int {
        return objectTuples.count
    }
    
    public func rowsInSection(_ section: Int) -> Int {
        guard section < objectTuples.count else { return 0 }
        
        return objectTuples[section].count
    }
    
    public var completeObjects: ([objectType]) -> Observable<[objectType]>
    
    public func objectAt(section: Int, row: Int) -> objectType? {
        guard section < objectTuples.count, row < objectTuples[section].count else { return nil }

        return objectTuples[section][row].object
    }
    
    public init(_ sectionDictionary: [(String, [objectType])], completeObjects: @escaping ([objectType]) -> Observable<[objectType]>) {
        self.completeObjects = completeObjects
        for objectSection in sectionDictionary {
            var section = [ObjectTuple]()
            for object in objectSection.1 {
                section.append(ObjectTuple(loadStatus: .initial, object: object))
            }
            objectTuples.append(section)
            _sectionTitles.append(objectSection.0)
        }
    }
    
    private func nextIndexPathDown(_ indexPath: IndexPath) -> IndexPath? {
        let section = indexPath[sectionIndex]
        let row = indexPath[rowIndex]
        
        if row > 0 {
            return IndexPath(indexes: [section, row - 1])
        }
        else if section > 0 {
            return IndexPath(indexes: [section - 1, objectTuples[section - 1].count - 1])
        }
        else {
            return nil
        }
    }
    
    private func nextIndexPathUp(_ indexPath: IndexPath) -> IndexPath? {
        let section = indexPath[sectionIndex]
        let row = indexPath[rowIndex]
        
        if row < objectTuples[section].count - 1 {
            return IndexPath(indexes: [section, row + 1])
        }
        else if section < objectTuples.count - 1 {
            return IndexPath(indexes: [section + 1, 0])
        }
        else {
            return nil
        }
    }
    
    public func getObjectObservable(indexPath: IndexPath) -> Observable<objectType> {
        let section = indexPath[sectionIndex]
        let row = indexPath[rowIndex]

        guard section < objectTuples.count,
            row < objectTuples[section].count else { return Observable.empty() }
        
        let tuple = objectTuples[section][row]
        if tuple.loadStatus != .initial {
            return tuple.objectSubject
        }
        
        var objectIndexes = [String: IndexPath]()
        tuple.loadStatus = .completionInProgress
        objectIndexes[tuple.object.id] = indexPath
        
        var objectsToFetch = [tuple.object]
        var indexPathDown: IndexPath? = indexPath
        for _ in 0..<30 {
            indexPathDown = nextIndexPathDown(indexPathDown!)
            if indexPathDown == nil {
                break
            }
            
            let downSection = indexPathDown![sectionIndex]
            let downRow = indexPathDown![rowIndex]
            let downTuple = objectTuples[downSection][downRow]
            if downTuple.loadStatus == .initial {
                objectsToFetch.append(downTuple.object)
                objectIndexes[downTuple.object.id] = indexPathDown!
                downTuple.loadStatus = .completionInProgress
            }
        }
        var indexPathUp: IndexPath? = indexPath
        for _ in 0..<30 {
            indexPathUp = nextIndexPathUp(indexPathUp!)
            if indexPathUp == nil {
                break
            }
            
            let upSection = indexPathUp![sectionIndex]
            let upRow = indexPathUp![rowIndex]
            let upTuple = objectTuples[upSection][upRow]
            if upTuple.loadStatus == .initial {
                objectsToFetch.append(upTuple.object)
                objectIndexes[upTuple.object.id] = indexPathUp!
                upTuple.loadStatus = .completionInProgress
            }
        }
        
        completeObjects(objectsToFetch)
            .subscribe(onNext: { [weak self] (objects) in
                guard let weakSelf = self else { return }
                
                for object in objects {
                    if let indexPath = objectIndexes[object.id] {
                        let section = indexPath[weakSelf.sectionIndex]
                        let row = indexPath[weakSelf.rowIndex]
                        
                        if section < weakSelf.objectTuples.count,
                            row < weakSelf.objectTuples[section].count {
                            let tuple = weakSelf.objectTuples[section][row]
                            tuple.loadStatus = .complete
                            tuple.object = object
                            tuple.objectSubject.onNext(object)
                        }
                    }
                }
            })
            .disposed(by: bag)
        
        return tuple.objectSubject
    }
    
    public func filter(_ filter: String) -> ObjectSections<objectType> {
        var filteredObjects = [objectType]()

        for section in 0..<objectTuples.count {
            for row in 0..<objectTuples[section].count {
                let tuple = objectTuples[section][row]
                
                if tuple.object.filter(filter) {
                    filteredObjects.append(tuple.object)
                }
            }
        }

        return ObjectSections<objectType>([("", filteredObjects)], completeObjects: completeObjects)
    }
}
