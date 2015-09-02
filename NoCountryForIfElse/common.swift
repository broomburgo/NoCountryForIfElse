
import Foundation

struct Person {
    
    let name: String
    let isYoung: Bool
    let childrenCount: Int
    let likedJobsMain: [String]
    let likedJobsSecondary: [String]
    let unlikedJobs: [String]
}

func printPersonData(person: Person) {
    println("isYoung: \(person.isYoung)")
    println("childrenCount: \(person.childrenCount)")
    println("likedJobsMain: \(person.likedJobsMain)")
    println("likedJobsSecondary: \(person.likedJobsSecondary)")
    println("unlikedJobs: \(person.unlikedJobs)")
}

let kProgrammer = "programmer"
let kJanitor = "janitor"
let kManager = "manager"
let kDentist = "dentist"
let kDoctor = "doctor"
let kPsycologist = "psycologist"
let kNurse = "nurse"
let kTeacher = "teacher"

let allJobs = [kProgrammer, kJanitor, kManager, kDentist, kDoctor, kPsycologist, kNurse, kTeacher]

func randomIntBetween(start: Int, and end: Int) -> Int {
    return Int(arc4random_uniform(UInt32(end+1-start))) + start
}

func randomBool() -> Bool {
    return randomIntBetween(1, and: 2) == 1
}

func matching<T: Equatable> (first: Array<T>, second: Array<T>) -> Bool {
    return reduce(first, false) { a, e in a || contains(second, e) }
}

func randomPerson() -> Person {
    
    let likedJobsMain = allJobs.filter { _ in randomBool() }
    let likedJobsSecondary = allJobs.filter { contains(likedJobsMain, $0) == false && randomBool() }
    let unlikedJobs = allJobs.filter { contains(likedJobsMain, $0) == false && contains(likedJobsSecondary, $0) == false && randomBool() }
    
    return Person(
        name: "random",
        isYoung: randomBool(),
        childrenCount: randomIntBetween(1, and: 3),
        likedJobsMain: likedJobsMain,
        likedJobsSecondary: likedJobsSecondary,
        unlikedJobs: unlikedJobs
    )
}