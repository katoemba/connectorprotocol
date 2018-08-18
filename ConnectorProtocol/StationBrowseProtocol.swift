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

public enum StationBrowseFilter {
    case genre(Genre)
    case search(String)
}

public protocol StationBrowseViewModel {
    var loadProgressObservable: Observable<LoadProgress> { get }
    var stationsObservable: Observable<[Station]> { get }
    var filters: [StationBrowseFilter] { get }
    
    func extend()
}

/// A protocol to provide a browsing protocol for radio stations.
/// This is kept separate from BrowseProtocol to allow an independent
/// implementation from the regular player browser, e.g. using a
/// service like shoutcast.
public protocol StationBrowseProtocol {
    /// Return a view model for a list of stations based on a search term, which can return stations in batches.
    ///
    /// - Parameter genre: search text to search for
    /// - Returns: a StationBrowseViewModel instance
    func stationBrowseViewModel(search: String) -> StationBrowseViewModel
    
    /// Return a view model for a list of albums filtered by genre, which can return albums in batches.
    ///
    /// - Parameter genre: genre to filter on
    /// - Returns: a StationBrowseViewModel instance
    func stationBrowseViewModel(genre: Genre) -> StationBrowseViewModel
    
    /// Return a view model for a preloaded list of stations.
    ///
    /// - Parameter stations: list of stations to show
    /// - Returns: a StationBrowseViewModel instance
    func stationBrowseViewModel(stations: [Station]) -> StationBrowseViewModel
    
    /// Return a view model for a list of genres, which can return genres in batches.
    ///
    /// - Returns: a GenreBrowseViewModel instance
    func genreBrowseViewModel() -> GenreBrowseViewModel    

    /// Return a view model for a list of genres, which can return genres in batches.
    ///
    /// - Parameter parentGenre: get subgenres of this genre
    /// - Returns: a GenreBrowseViewModel instance
    func genreBrowseViewModel(parentGenre: Genre) -> GenreBrowseViewModel
}
