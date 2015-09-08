
typealias PersonCheck = Person -> Bool

infix operator <&> {
    associativity left
    precedence 120
}
func <&> (left: PersonCheck, right: PersonCheck) -> PersonCheck {
    return { left($0) && right($0) }
}

infix operator <|> {
    associativity left
    precedence 110
}
func <|> (left: PersonCheck, right: PersonCheck) -> PersonCheck {
    return { left($0) || right($0) }
}

infix operator <*> {
    associativity left
    precedence 100
}
func <*> <A,B> (left: A -> B, right: A) -> B {
    return left(right)
}

/// person attributes

func checkAlways() -> PersonCheck {
    return { _ in true}
}

func checkMinLikedJobsCount(minCount: Int) -> PersonCheck {
    return { $0.likedJobsMain.count >= minCount }
}

func checkYoung(isYoung: Bool) -> PersonCheck {
    return { $0.isYoung == isYoung }
}

func checkChildrenCount(count: Int) -> PersonCheck {
    return { $0.childrenCount == count }
}

func checkChildrenMinCount(count: Int) -> PersonCheck {
    return { $0.childrenCount >= count }
}

/// jobs

func checkMainJobs(jobs: [String]) -> PersonCheck {
    return { matching($0.likedJobsMain, jobs) }
}

func checkSecondaryJobs(jobs: [String]) -> PersonCheck {
    return { matching($0.likedJobsSecondary, jobs) }
}

func checkExtendedJobs(jobs: [String]) -> PersonCheck {
    return checkMainJobs(jobs) <|> checkSecondaryJobs(jobs)
}

func checkAllJobs(jobs: [String]) -> PersonCheck {
    return { person in jobs.filter({ contains(person.unlikedJobs, $0) == false }).count > 0 }
}

/// composite

func mustFail(checks: [PersonCheck]) -> PersonCheck {
    return { person in checks.reduce(true) { value, check in value && (check(person) == false) } }
}

func mustSucceed(checks: [PersonCheck]) -> PersonCheck {
    return { person in checks.reduce(true) { value, check in value && check(person) } }
}

/// nodes

struct DeskNode {
    let name: String
    let nextDeskName: String?
}

typealias PersonNode = Person -> DeskNode
typealias JobsNode = PersonCheck -> PersonNode

func node(name: String, #nextDeskName: String) -> JobsNode {
    return { check in
        return { person in
            return DeskNode(name: name, nextDeskName: check(person) ? nextDeskName : nil)
        }
    }
}

/// main function

func placeNameForPerson_functional(person: Person, #nodes: [PersonNode]) -> String {
    if let deskName = nodes.reduce(String?(), combine: { $0 ?? $1(person).nextDeskName }) {
        return "at desk \(deskName)"
    }
    else {
        return "outside"
    }
}

/// check

func quickCheck_functional(nodes: [PersonNode], #iterations: Int, #verbose: Bool) {
    for _ in (1...iterations) {
        let person = randomPerson()
        if verbose {
            println()
            println("testing person:")
            printPersonData(person)
        }
        let passingNodes = nodes.reduce([String]()) { currentNodeNames, node in
            if let nextDeskName = node(person).nextDeskName {
                var m_nodes = currentNodeNames
                m_nodes.append("\(node(person).name)")
                return m_nodes
            }
            else {
                return currentNodeNames
            }
        }
        if passingNodes.count > 1 {
            fatalError("ambiguous nodes: \(passingNodes)")
        }
        else if verbose {
            println("testing PASSED")
        }
    }
}

