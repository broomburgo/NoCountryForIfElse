
protocol Place {
    func accept(movable: Movable) -> String
}

struct Desk: Place {
    let name: String
    func accept(movable: Movable) -> String {
        return "at desk \(name)"
    }
}

struct Outside: Place {
    func accept(movable: Movable) -> String {
        return "outside"
    }
}

protocol Movable {
    func goToPlace(place: Place) -> String
}

struct DeskWithJobs: Place {
    let desk: Desk
    let availableJobs: [String]
    let availableJobsOneChild: [String]
    let availableJobsTwoChildren: [String]
    let availableJobsElderly: [String]
    let minJobsListSize: Int
    
    func accept(movable: Movable) -> String {
        return desk.accept(movable)
    }
}

extension Person {
    
    func chooseJob(jobs: [String]) -> Bool {
        return (likedJobsMain + likedJobsSecondary).reduce(false) { $0 ? $0 : contains(jobs, $1) }
    }
}

extension Person: Movable {
    
    func goToPlace(place: Place) -> String {
        return place.accept(self)
    }
    
    var description: String {
        return name
    }
}

func getStringsFromList(list: [String], optionalPreferences: [String]?) -> [String] {
    
    if let preferences = optionalPreferences {
        return list.filter { contains(preferences, $0) }
    } else {
        return list
    }
}

/// main function

func placeNameForPerson_structured(person: Person, #desk: DeskWithJobs) -> String {
    
    let outside = Outside()
        
    if person.childrenCount == 0 {
        if person.isYoung {
            var l1 = person.likedJobsMain
            if l1.count < desk.minJobsListSize {
                l1 = l1 + person.likedJobsSecondary
            }
            var l2 = getStringsFromList(desk.availableJobs, l1)
            if l2.count == 0 {
                if desk.availableJobs.filter({ contains(person.dislikedJobs, $0) == false }).count > 0 {
                    return person.goToPlace(Desk(name: "d2"))
                }
                else {
                    return person.goToPlace(outside)
                }
            }
            else {
                if person.chooseJob(l2) {
                    return person.goToPlace(Desk(name: "d2"))
                }
                else {
                    if desk.availableJobs.filter({ contains(person.dislikedJobs, $0) == false }).count > 0 {
                        return person.goToPlace(Desk(name: "d2"))
                    }
                    else {
                        return person.goToPlace(outside)
                    }
                }
            }
        }
        else {
            let l3 = desk.availableJobsElderly
            if l3.count == 0 {
                return person.goToPlace(outside)
            }
            else {
                if person.chooseJob(l3) {
                    return person.goToPlace(Desk(name: "d3"))
                }
                else {
                    return person.goToPlace(outside)
                }
            }
        }
    }
    else {
        switch person.childrenCount {
        case 1:
            let l4 = desk.availableJobsOneChild
            if person.chooseJob(l4) {
                return person.goToPlace(Desk(name: "d4"))
            }
            else {
                return person.goToPlace(Outside())
            }
        case 2:
            let l5 = desk.availableJobsTwoChildren
            if person.chooseJob(l5) {
                return person.goToPlace(Desk(name: "d4"))
            }
            else {
                return person.goToPlace(Outside())
            }
        default:
            return person.goToPlace(Desk(name: "d5"))
        }
    }
}
