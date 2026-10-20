import QtQuick
import qs.Constants

Behavior {
    id: motion

    property real epsilon: Theme.motion.springEpsilon

    SpringAnimation {
        spring: Theme.motion.springStiffness
        damping: Theme.motion.springDamping
        epsilon: motion.epsilon
    }
}
