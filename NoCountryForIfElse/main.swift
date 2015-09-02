
/// shared definitions

let p1 = Person(
    name: "p1",
    isYoung: true,
    childrenCount: 0,
    likedJobsMain: [],
    likedJobsSecondary: [],
    unlikedJobs: []
)

let availableJobs = [kProgrammer,kJanitor,kManager]
let availableJobsOneChild = [kProgrammer,kJanitor]
let availableJobsTwoChildren = [kJanitor,kPsycologist]
let availableJobsElderly = [kManager,kDoctor,kDentist,kProgrammer]
let minJobsListSize = 1

////////////

/// definitions for procedural

let desk = DeskWithJobs(
    desk: Desk(name: "d1"),
    availableJobs: availableJobs,
    availableJobsOneChild: availableJobsOneChild,
    availableJobsTwoChildren: availableJobsTwoChildren,
    availableJobsElderly: availableJobsElderly,
    minJobsListSize: minJobsListSize
)

////////////

/// definitions for OO

let checkThreeOrMoreChildren = ChildrenCountCheck(3)
let checkTwoChildren = ChildrenCountCheck(2)
let checkOneChild = ChildrenCountCheck(1)
let checkOld = IsYoungCheck(false)
let checkMain = MinLikedJobsCountCheck(minJobsListSize)

let checkFailingChildrenAll = MultipleCheck([
    FailingCheck(checkOneChild),
    FailingCheck(checkTwoChildren),
    FailingCheck(checkThreeOrMoreChildren)
    ])

let structure = CheckStructure([
    
    CheckNode(
        name: "3 or more children",
        nextDeskName: "d5",
        check: checkThreeOrMoreChildren
    ),
    CheckNode(
        name: "2 children",
        nextDeskName: "d4",
        check:ComposedCheck(checkTwoChildren)
            .composeWith(ExtendedJobsCheck(availableJobsTwoChildren))
    ),
    CheckNode(
        name: "1 child",
        nextDeskName: "d4",
        check: ComposedCheck(checkOneChild)
            .composeWith(ExtendedJobsCheck(availableJobsOneChild))
    ),
    CheckNode(
        name: "old",
        nextDeskName: "d3",
        check: ComposedCheck(checkOld)
            .composeWith(checkFailingChildrenAll)
            .composeWith(ExtendedJobsCheck(availableJobsElderly))
    ),
    CheckNode(
        name: "main",
        nextDeskName: "d2",
        check: ComposedCheck(checkMain)
            .composeWith(checkFailingChildrenAll)
            .composeWith(FailingCheck(checkOld))
            .composeWith(MainJobsCheck(availableJobs))
    ),
    CheckNode(
        name: "secondary",
        nextDeskName: "d2",
        check: ComposedCheck(checkFailingChildrenAll)
            .composeWith(FailingCheck(checkOld))
            .composeWith(FailingCheck(MainJobsCheck(availableJobs)))
            .composeWith(SecondaryJobsCheck(availableJobs))
    ),
    CheckNode(
        name: "any",
        nextDeskName: "d2",
        check: ComposedCheck(checkFailingChildrenAll)
            .composeWith(FailingCheck(checkOld))
            .composeWith(FailingCheck(MainJobsCheck(availableJobs)))
            .composeWith(FailingCheck(SecondaryJobsCheck(availableJobs)))
            .composeWith(AllJobsCheck(availableJobs))
    )
    ])

////////////

/// definitions for functional

let threeOrMoreChildrenCheck = checkChildrenCount(3)
let twoChildrenCheck = checkChildrenCount(2)
let oneChildCheck = checkChildrenCount(1)
let oldCheck = checkYoung(false)
let mainCheck = checkMinLikedJobsCount(minJobsListSize)

let childrenChecks = [oneChildCheck,twoChildrenCheck,threeOrMoreChildrenCheck]

let nodes: [PersonNode] = [
    
    node("3 or more children", nextDeskName: "d5")
        <*> threeOrMoreChildrenCheck,
    
    node("2 children", nextDeskName: "d4")
        <*> twoChildrenCheck
        <&> checkExtendedJobs(availableJobsTwoChildren),
    
    node("1 child", nextDeskName: "d4")
        <*> oneChildCheck
        <&> checkExtendedJobs(availableJobsOneChild),
    
    node("old", nextDeskName: "d3")
        <*> oldCheck <&> mustFail(childrenChecks)
        <&> checkExtendedJobs(availableJobsElderly),
    
    node("main", nextDeskName: "d2")
        <*> mainCheck
        <&> mustFail(childrenChecks + [oldCheck])
        <&> checkMainJobs(availableJobs),
    
    node("secondary", nextDeskName: "d2")
        <*> mustFail(childrenChecks + [oldCheck, mainCheck])
        <&> checkSecondaryJobs(availableJobs),
    
    node("any", nextDeskName: "d2")
        <*> mustFail(childrenChecks + [oldCheck, mainCheck, checkSecondaryJobs(availableJobs)])
        <&> checkAllJobs(availableJobs)
]

////////////

quickCheck_oo(structure, iterations: 10000, verbose: false)
quickCheck_functional(nodes, iterations: 10000, verbose: false)

println()
println("COMPLEX\n")
println("\(p1.name) is at desk d1")
let placeName_complex = placeNameForPerson_complex(p1, desk: desk)
println("\(p1.name) is \(placeName_complex)")

println("\n------------\n")

println("FUNCTIONAL\n")
println("\(p1.name) is at desk d1")
let placeName_functional = placeNameForPerson_functional(p1, nodes: nodes)
println("\(p1.name) is \(placeName_functional)")

println("\n------------\n")

println("OO\n")
println("\(p1.name) is at desk d1")
let placeName_oo = placeNameForPerson_oo(p1, structure:structure)
println("\(p1.name) is \(placeName_oo)")

////////////

/// consistency check

func quickCheck_consistency(desk: DeskWithJobs, structure: CheckStructure, nodes: [PersonNode], #iterations: Int, #verbose: Bool) {
    for _ in (1...iterations) {
        let person = randomPerson()
        if verbose {
            println()
            println("testing person:")
            printPersonData(person)
        }
        let placeNameForComplex = placeNameForPerson_complex(person, desk: desk)
        let placeNameForOO = placeNameForPerson_oo(person, structure: structure)
        let placeNameForFunctional = placeNameForPerson_functional(person, nodes: nodes)
        if placeNameForComplex != placeNameForOO {
            fatalError("incostistent result for complex and OO operations\nplace name for complex: \(placeNameForComplex)\nplace name for OO: \(placeNameForOO)")
        }
        if placeNameForComplex != placeNameForFunctional {
            fatalError("incostistent result for complex and functional operations\nplace name for complex: \(placeNameForComplex)\nplace name for functional: \(placeNameForFunctional)")
        }
        if placeNameForOO != placeNameForFunctional {
            fatalError("incostistent result for OO and functional operations\nplace name for OO: \(placeNameForOO)\nplace name for functional: \(placeNameForFunctional)")
        }
        if verbose {
            println("testing PASSED")
        }
    }
}
quickCheck_consistency(desk, structure, nodes, iterations: 10000, verbose: false)
