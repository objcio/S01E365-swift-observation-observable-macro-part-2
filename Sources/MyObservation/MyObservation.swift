import SwiftSyntaxMacros

@attached(member, names: named(_registrar), arbitrary)
@attached(memberAttribute)
macro MyObservable() = #externalMacro(module: "MyObservationMacros", type: "MyObservableMacro")

@attached(accessor)
macro MyObservedProperty() = #externalMacro(module: "MyObservationMacros", type: "MyObservedPropertyMacro")

struct Entry {
    var keyPaths: Set<AnyKeyPath> = []
    var registrar: Registrar
}

final class Registrar {
    typealias Observer = () -> ()
    typealias ObservedID = Int
    var freshID = 0
    var observers: [ObservedID: Observer] = [:]
    var observations: [AnyKeyPath: Set<ObservedID>] = [:]

    func access<Source: AnyObject, Target>(_ obj: Source, _ keyPath: KeyPath<Source, Target>) {
        accessList[ObjectIdentifier(obj), default: Entry(registrar: self)].keyPaths.insert(keyPath)
    }

    func addObserver(_ observer: @escaping Observer, for keyPaths: Set<AnyKeyPath>) -> ObservedID{
        let id = freshID
        freshID += 1
        observers[id] = observer
        for kp in keyPaths {
            observations[kp, default: []].insert(id)
        }
        return id
    }

    func removeObserver(id: ObservedID) {
        observers[id] = nil
        for key in observations.keys {
            observations[key]!.remove(id)
            if observations[key]!.isEmpty {
                observations[key] = nil
            }
        }
    }

    func willSet<Source: AnyObject, Target>(_ obj: Source, _ keyPath: KeyPath<Source, Target>) {
        guard let obIDs = observations[keyPath] else { return }
        for id in obIDs {
            observers[id]?()
        }
    }
}

var accessList: [ObjectIdentifier: Entry] = [:]

func withObservationTracking<T>(_ apply: () -> T, onChange: @escaping () -> ()) -> T {
    let result = apply()
    var removeObservers: [() -> ()] = []
    let fire = {
        onChange()
        for r in removeObservers {
            r()
        }
    }
    for (obj, entry) in accessList {
        let id = entry.registrar.addObserver(fire, for: entry.keyPaths)
        removeObservers.append({ entry.registrar.removeObserver(id: id) })
    }
    return result
}
