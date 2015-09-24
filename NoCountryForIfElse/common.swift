
import Foundation

struct Person
{
  let name: String
  let isYoung: Bool
  let childrenCount: Int
  let likedJobsMain: [String]
  let likedJobsSecondary: [String]
  let dislikedJobs: [String]
}

func printPersonData (person: Person)
{
  print("isYoung: \(person.isYoung)")
  print("childrenCount: \(person.childrenCount)")
  print("likedJobsMain: \(person.likedJobsMain)")
  print("likedJobsSecondary: \(person.likedJobsSecondary)")
  print("dislikedJobs: \(person.dislikedJobs)")
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

func randomIntBetween (start: Int, _ end: Int) -> Int
{
  return Int(arc4random_uniform(UInt32(end+1-start))) + start
}

func randomBool () -> Bool
{
  return randomIntBetween(1, 2) == 1
}

func matching <T: Equatable> (first: Array<T>, _ second: Array<T>) -> Bool
{
  return first.reduce(false) { a, e in a || second.contains(e) }
}

func randomPerson () -> Person
{
  let likedJobsMain = allJobs.filter { _ in randomBool() }
  let likedJobsSecondary = allJobs.filter { likedJobsMain.contains($0) == false && randomBool() }
  let dislikedJobs = allJobs.filter { likedJobsMain.contains($0) == false && likedJobsSecondary.contains($0) == false && randomBool() }
  
  return Person(
    name: "random",
    isYoung: randomBool(),
    childrenCount: randomIntBetween(1, 3),
    likedJobsMain: likedJobsMain,
    likedJobsSecondary: likedJobsSecondary,
    dislikedJobs: dislikedJobs
  )
}

extension Optional
{
  func getOrElse (@autoclosure elseValue: () -> Wrapped) -> Wrapped
  {
    return self ?? elseValue()
  }
}