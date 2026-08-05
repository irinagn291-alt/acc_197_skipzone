import Combine
import SwiftUI

final class VMHolder<VM: ObservableObject>: ObservableObject {
    @Published private(set) var object: VM

    init(_ object: VM) {
        self.object = object
    }
}
