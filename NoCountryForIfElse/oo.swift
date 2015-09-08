
/// person attributes

protocol PersonCheckType {
    func personIsValid(person: Person) -> Bool
}

class AlwaysPassCheck: PersonCheckType {
    
    func personIsValid(person: Person) -> Bool {
        return true
    }
}

class MinLikedJobsCountCheck: PersonCheckType {
    
    let minCount: Int
    init(_ minCount: Int) {
        self.minCount = minCount
    }
    
    func personIsValid(person: Person) -> Bool {
        return person.likedJobsMain.count >= minCount
    }
}

class IsYoungCheck: PersonCheckType {
    
    let isYoung: Bool
    init(_ isYoung: Bool) {
        self.isYoung = isYoung
    }
    
    func personIsValid(person: Person) -> Bool {
        return person.isYoung == isYoung
    }
}

class ChildrenCountCheck: PersonCheckType {
    
    let childrenCount: Int
    init(_ childrenCount: Int) {
        self.childrenCount = childrenCount
    }
    
    func personIsValid(person: Person) -> Bool {
        return person.childrenCount == childrenCount
    }
}

class ChildrenMinCountCheck: PersonCheckType {
    
    let childrenMinCount: Int
    init(_ childrenMinCount: Int) {
        self.childrenMinCount = childrenMinCount
    }
    
    func personIsValid(person: Person) -> Bool {
        return person.childrenCount >= childrenMinCount
    }
}

/// jobs

class JobsType {
    
    let availableJobs: [String]
    
    init(_ availableJobs: [String]) {
        self.availableJobs = availableJobs
    }
}

class MainJobsCheck: JobsType, PersonCheckType {
    
    func personIsValid(person: Person) -> Bool {
        return matching(availableJobs, person.likedJobsMain)
    }
}

class SecondaryJobsCheck: JobsType, PersonCheckType {
    
    func personIsValid(person: Person) -> Bool {
        return matching(availableJobs, person.likedJobsSecondary)
    }
}

class ExtendedJobsCheck: JobsType, PersonCheckType {
    
    func personIsValid(person: Person) -> Bool {
        return matching(availableJobs, person.likedJobsMain + person.likedJobsSecondary)
    }
}

class AllJobsCheck: JobsType, PersonCheckType {
    
    func personIsValid(person: Person) -> Bool {
        return availableJobs.filter({ contains(person.unlikedJobs, $0) == false }).count > 0
    }
}

/// composition

class FailingCheck: PersonCheckType {
    
    let check: PersonCheckType
    
    init(_ check: PersonCheckType) {
        self.check = check
    }
    
    func personIsValid(person: Person) -> Bool {
        return check.personIsValid(person) == false
    }
}

class MultipleCheck: PersonCheckType {
    
    let checks: [PersonCheckType]
    
    init(_ checks: [PersonCheckType]) {
        self.checks = checks
    }

    func personIsValid(person: Person) -> Bool {
        return checks.reduce(true) { $0 && $1.personIsValid(person) }
    }
}

class ComposedCheck: PersonCheckType {
    
    let basic: PersonCheckType
    
    init(_ basic: PersonCheckType) {
        self.basic = basic
    }
    
    func composeWith(check: PersonCheckType) -> ComposedCheck {
        return ComposedCheck(MultipleCheck([basic,check]))
    }
    
    func personIsValid(person: Person) -> Bool {
        return basic.personIsValid(person)
    }
}

/// desk name retrieval

protocol NextDeskType {
    func nextDeskNameForPerson(person: Person) -> String?
}

class CheckNode: NextDeskType {
    
    let name: String
    let nextDeskName: String
    let check: PersonCheckType
    
    init(name: String, nextDeskName: String, check: PersonCheckType) {
        self.name = name
        self.nextDeskName = nextDeskName
        self.check = check
    }
    
    func nextDeskNameForPerson(person: Person) -> String? {
        return check.personIsValid(person) ? nextDeskName : nil
    }
}

class CheckStructure: NextDeskType {
    
    let nodes: [CheckNode]
    init(_ nodes: [CheckNode]) {
        self.nodes = nodes
    }
    
    func nextDeskNameForPerson(person: Person) -> String? {
        return nodes.reduce(String?()) {
            $0 ?? $1.nextDeskNameForPerson(person)
        }
    }
    
    func validNodesNamesforPerson(person: Person) -> [String] {
        return nodes.reduce([String]()) { accumulator, node in
            var m_accumulator = accumulator
            if let nextDeskName = node.nextDeskNameForPerson(person) {
                m_accumulator.append(node.name)
            }
            return m_accumulator
        }
    }
}

/// main function

func placeNameForPerson_oo(person: Person, #structure: CheckStructure) -> String {
    if let deskName = structure.nextDeskNameForPerson(person) {
        return "at desk \(deskName)"
    }
    else {
        return "outside"
    }
}

/// check

func quickCheck_oo(structure: CheckStructure, #iterations: Int, #verbose: Bool) {
    for _ in (1...iterations) {
        let person = randomPerson()
        if verbose {
            println()
            println("testing person:")
            printPersonData(person)
        }
        let passingNodes = structure.validNodesNamesforPerson(person)
        if passingNodes.count > 1 {
            fatalError("ambiguous nodes: \(passingNodes)")
        }
        else if verbose {
            println("testing PASSED")
        }
    }
}




