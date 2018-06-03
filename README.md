# README #

### What is this repository for? ###

* ConnectorProtocol is a generic protocol specification to control a network based music player for Swift.
The protocol abstracts a player specific implementation from a client implementation, which allows to have
a single client that supports multiple player types.
* MPDConnector is a full implementation of this protocol for the MPD protocol.
* These two libraries are the foundation of the Rigelian MPD client, for more info see http://www.rigelian.net

### What are the building blocks of this Protocol? ###

* The protocol uses reactive constructs, based on RxSwift.
* ConnectorProtocol consist of five sub-protocols:
  * PlayerProtocol defines a basic player, access status, control and browse implementation, 
    plus functions to maintain player-specific settings.
  * PlayerBrowserProtocol is a generic protocol to detect players on the network.
  * StatusProtocol is a protocol through which the connection status of a player, 
    as well as the music-playing status can be monitored.
  * ControlProtocol is a protocol through which commands can be sent to a player, like play, pause, add a song etc.
  * BrowseProtocol is a protocol through which you can browse through the music on a player. 
    It defines various ViewModels for artists, albums, genres etc.
* A number of basic objects are defined:
  * Album
  * Artist
  * Song
  * Playlist
  * Folder
  * PlayerStatus


### How do I get set up? ###

* Summary of set up
* Configuration
* Dependencies
* Database configuration
* How to run tests
* Deployment instructions

### Contribution guidelines ###

* Writing tests
* Code review
* Other guidelines

### Who do I talk to? ###

* In case of questions you can contact berrie @ rigelian dot net