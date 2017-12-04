//
//  EventUp_Tests.swift
//  EventUp!Tests
//
//  Created by Siraj Zaneer on 12/3/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import XCTest
import Firebase

@testable import EventUp_

class EventUp_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSignUpAndDeleteUser() {
        var users: [Dictionary<String, String>] = []
        
        users.append(["email": "test1@gmail.com",
                      "password": "test1password",
                      "username": "test1"
            ])
        users.append(["email": "test2@gmail.com",
                      "password": "test2password",
                      "username": "test2"
            ])
        users.append(["email": "test3@gmail.com",
                      "password": "tester4",
                      "username": "test3"
            ])
        users.append(["email": "test4@gmail.com",
                      "password": "tester4",
                      "username": "test4"
            ])
        
        let image = UIImage(named: "sidebarIcon")
        let expect = expectation(description: "Create users")
        expect.expectedFulfillmentCount = users.count
        for user in users {
            EventUpClient.sharedInstance.registerUser(userData: user, userImage: image, success: { (newUser) in
                newUser.delete(completion: { (error) in
                    if let error = error {
                        XCTFail(error.localizedDescription)
                    } else {
                        try! Auth.auth().signOut()
                        EventUpClient.sharedInstance.deleteUser(uid: newUser.uid, success: {
                            
                            expect.fulfill()
                        }, failure: { (error) in
                            XCTFail(error.localizedDescription)
                        })
                    }
                })
            }) { (error) in
                XCTFail(error.localizedDescription)
            }
        }
        self.waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testCreateEvent() {
        var events: [[String: Any]] = []
        
        let currDate = Double(Date().timeIntervalSince1970)
        
        let event1 = ["date": currDate, "endDate": currDate, "location": "test", "info": "information",
                      "latitude": 43.934857, "longitude": 24.029348, "name": "title"] as [String : Any]
        
        let event2 = ["date": currDate, "endDate": currDate, "location": "test", "info": "information",
                      "latitude": 43.934857, "longitude": 24.029348, "name": "title"] as [String : Any]
        
        let event3 = ["date": currDate, "endDate": currDate, "location": "test", "info": "information",
                      "latitude": 43.934857, "longitude": 24.029348, "name": "title", "tags": ["Social"]] as [String : Any]
        
        let event4 = ["date": currDate, "endDate": currDate, "location": "test", "info": "information",
                      "latitude": 43.934857, "longitude": 24.029348, "name": "title", "tags": ["Social", "Other"]] as [String : Any]
        
        events.append(event1)
        events.append(event2)
        events.append(event3)
        events.append(event4)
        
        let image = UIImage(named: "sidebarIcon")
        
        let expect = expectation(description: "Create Events")
        expect.expectedFulfillmentCount = events.count
        
        Auth.auth().signIn(withEmail: "tester@example.com", password: "123456") { (user, error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            } else if let user = user {
                for event in events {
                    var eventData = event
                    eventData["owner"] = user.uid
                    EventUpClient.sharedInstance.createEvent(eventData: eventData, eventImage: image, success: { (event) in
                        expect.fulfill()
                    }, failure: { (error) in
                        XCTFail(error.localizedDescription)
                    })
                }
            }
        }
        self.waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testEditEvent() {
        
        let currDate = Double(Date().timeIntervalSince1970)
        
        var event = ["date": currDate, "endDate": currDate, "location": "test", "info": "information",
                     "latitude": 43.934857, "longitude": 24.029348, "name": "title", "tags": ["Social", "Other"]] as [String : Any]
        let newInfo = ["date": currDate, "endDate": currDate + 120, "location": "tedfst", "info": "infordfdfmation",
                       "latitude": 44.934857, "longitude": 22.029348, "name": "title", "tags": ["Social"]] as [String : Any]
        
        let image = UIImage(named: "sidebarIcon")
        let expect = expectation(description: "Edit Event")
        
        Auth.auth().signIn(withEmail: "tester@example.com", password: "123456") { (user, error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            } else if let user = user {
                event["owner"] = user.uid
                EventUpClient.sharedInstance.createEvent(eventData: event, eventImage: image, success: { (newEvent) in
                    EventUpClient.sharedInstance.editEvent(event: newEvent, eventData: newInfo, eventImage: image, success: {
                        expect.fulfill()
                    }, failure: { (error) in
                        XCTFail(error.localizedDescription)
                    })
                }, failure: { (error) in
                    XCTFail(error.localizedDescription)
                })
            }
        }
        self.waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testGetUserData() {
        let expect = expectation(description: "Get user data")
        
        Auth.auth().signIn(withEmail: "tester@example.com", password: "123456") { (user, error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            } else if let user = user {
                EventUpClient.sharedInstance.getUserInfo(user: user.uid, success: { (user) in
                    expect.fulfill()
                }, failure: { (error) in
                    XCTFail(error.localizedDescription)
                })
            }
        }
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testGetEvents() {
        let expect = expectation(description: "Get events")
        EventUpClient.sharedInstance.getEvents(success: { (events) in
            expect.fulfill()
        }) { (error) in
            XCTFail(error.localizedDescription)
        }
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testGetEventData() {
        let expect = expectation(description: "Get event data")
        
        let currDate = Double(Date().timeIntervalSince1970)
        
        var event = ["date": currDate, "endDate": currDate, "location": "test", "info": "information",
                     "latitude": 43.934857, "longitude": 24.029348, "name": "title"] as [String : Any]
        
        Auth.auth().signIn(withEmail: "tester@example.com", password: "123456") { (user, error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            } else if let user = user {
                event["owner"] = user.uid
                let image = UIImage(named: "sidebarIcon")
                EventUpClient.sharedInstance.createEvent(eventData: event, eventImage: image, success: { (event) in
                    EventUpClient.sharedInstance.getEvent(uid: event.uid, success: { (user) in
                        expect.fulfill()
                    }, failure: { (error) in
                        XCTFail(error.localizedDescription)
                    })
                }, failure: { (error) in
                    XCTFail(error.localizedDescription)
                })
                
            }
        }
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testDeleteEvent() {
        var events: [[String: Any]] = []
        
        let currDate = Double(Date().timeIntervalSince1970)
        
        let event1 = ["date": currDate, "endDate": currDate, "location": "test", "info": "information",
                      "latitude": 43.934857, "longitude": 24.029348, "name": "title"] as [String : Any]
        
        let event2 = ["date": currDate, "endDate": currDate, "location": "test", "info": "information",
                      "latitude": 43.934857, "longitude": 24.029348, "name": "title"] as [String : Any]
        
        let event3 = ["date": currDate, "endDate": currDate, "location": "test", "info": "information",
                      "latitude": 43.934857, "longitude": 24.029348, "name": "title", "tags": ["Social"]] as [String : Any]
        
        let event4 = ["date": currDate, "endDate": currDate, "location": "test", "info": "information",
                      "latitude": 43.934857, "longitude": 24.029348, "name": "title", "tags": ["Social", "Other"]] as [String : Any]
        
        events.append(event1)
        events.append(event2)
        events.append(event3)
        events.append(event4)
        
        let image = UIImage(named: "sidebarIcon")
        
        let expect = expectation(description: "Create Events")
        expect.expectedFulfillmentCount = events.count
        
        Auth.auth().signIn(withEmail: "tester@example.com", password: "123456") { (user, error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            } else if let user = user {
                for event in events {
                    var eventData = event
                    eventData["owner"] = user.uid
                    EventUpClient.sharedInstance.createEvent(eventData: eventData, eventImage: image, success: { (event) in
                        EventUpClient.sharedInstance.deleteEvent(event: event, success: {
                            expect.fulfill()
                        }, failure: { (error) in
                            XCTFail(error.localizedDescription)
                        })
                    }, failure: { (error) in
                        XCTFail(error.localizedDescription)
                    })
                }
            }
        }
        self.waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testEventRsvp() {
        let expect = expectation(description: "Event RSVP")
        
        let currDate = Double(Date().timeIntervalSince1970)
        
        var event = ["date": currDate, "endDate": currDate, "location": "test", "info": "information",
                     "latitude": 43.934857, "longitude": 24.029348, "name": "title"] as [String : Any]
        
        Auth.auth().signIn(withEmail: "tester@example.com", password: "123456") { (user, error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            } else if let user = user {
                event["owner"] = user.uid
                let image = UIImage(named: "sidebarIcon")
                EventUpClient.sharedInstance.createEvent(eventData: event, eventImage: image, success: { (event) in
                    EventUpClient.sharedInstance.rsvpEvent(event: event, uid: user.uid, success: { (count) in
                        EventUpClient.sharedInstance.deleteEvent(event: event, success: {
                            expect.fulfill()
                        }, failure: { (error) in
                            XCTFail(error.localizedDescription)
                        })
                    }, failure: { (error) in
                        XCTFail(error.localizedDescription)
                    })
                }, failure: { (error) in
                    XCTFail(error.localizedDescription)
                })
                
            }
        }
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testEventCheckin() {
        let expect = expectation(description: "Event Checkin")
        
        let currDate = Double(Date().timeIntervalSince1970)
        
        var event = ["date": currDate, "endDate": currDate, "location": "test", "info": "information",
                     "latitude": 43.934857, "longitude": 24.029348, "name": "title", "tags": ["Social"]] as [String : Any]
        
        Auth.auth().signIn(withEmail: "tester@example.com", password: "123456") { (user, error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            } else if let user = user {
                event["owner"] = user.uid
                let image = UIImage(named: "sidebarIcon")
                EventUpClient.sharedInstance.createEvent(eventData: event, eventImage: image, success: { (event) in
                    EventUpClient.sharedInstance.checkInEvent(event: event, uid: user.uid, success: { (count) in
                        EventUpClient.sharedInstance.deleteEvent(event: event, success: {
                            expect.fulfill()
                        }, failure: { (error) in
                            XCTFail(error.localizedDescription)
                        })
                    }, failure: { (error) in
                        XCTFail(error.localizedDescription)
                    })
                }, failure: { (error) in
                    XCTFail(error.localizedDescription)
                })
                
            }
        }
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testEventCheckinCancel() {
        let expect = expectation(description: "Event Checkin Cancel")
        
        let currDate = Double(Date().timeIntervalSince1970)
        
        var event = ["date": currDate, "endDate": currDate, "location": "test", "info": "information",
                     "latitude": 43.934857, "longitude": 24.029348, "name": "title", "tags": ["Social"]] as [String : Any]
        
        Auth.auth().signIn(withEmail: "tester@example.com", password: "123456") { (user, error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            } else if let user = user {
                event["owner"] = user.uid
                let image = UIImage(named: "sidebarIcon")
                EventUpClient.sharedInstance.createEvent(eventData: event, eventImage: image, success: { (event) in
                    EventUpClient.sharedInstance.checkInEvent(event: event, uid: user.uid, success: { (count) in
                        EventUpClient.sharedInstance.checkInEvent(event: event, uid: user.uid, success: { (count) in
                            EventUpClient.sharedInstance.deleteEvent(event: event, success: {
                                expect.fulfill()
                            }, failure: { (error) in
                                XCTFail(error.localizedDescription)
                            })
                        }, failure: { (error) in
                            XCTFail(error.localizedDescription)
                        })
                    }, failure: { (error) in
                        XCTFail(error.localizedDescription)
                    })
                }, failure: { (error) in
                    XCTFail(error.localizedDescription)
                })
                
            }
        }
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testEventRsvpCancel() {
        let expect = expectation(description: "Event RSVP")
        
        let currDate = Double(Date().timeIntervalSince1970)
        
        var event = ["date": currDate, "endDate": currDate, "location": "test", "info": "information",
                     "latitude": 43.934857, "longitude": 24.029348, "name": "title"] as [String : Any]
        
        Auth.auth().signIn(withEmail: "tester@example.com", password: "123456") { (user, error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            } else if let user = user {
                event["owner"] = user.uid
                let image = UIImage(named: "sidebarIcon")
                EventUpClient.sharedInstance.createEvent(eventData: event, eventImage: image, success: { (event) in
                    EventUpClient.sharedInstance.rsvpEvent(event: event, uid: user.uid, success: { (count) in
                        EventUpClient.sharedInstance.cancelRsvpEvent(event: event, uid: user.uid, success: { (count) in
                            EventUpClient.sharedInstance.deleteEvent(event: event, success: {
                                expect.fulfill()
                            }, failure: { (error) in
                                XCTFail(error.localizedDescription)
                            })
                        }, failure: { (error) in
                            XCTFail(error.localizedDescription)
                        })
                    }, failure: { (error) in
                        XCTFail(error.localizedDescription)
                    })
                }, failure: { (error) in
                    XCTFail(error.localizedDescription)
                })
                
            }
        }
        
        waitForExpectations(timeout: 30, handler: nil)
    }
}

