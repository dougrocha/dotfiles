pragma Singleton
import QtQuick
import Quickshell

Singleton {
	<* for name, value in colors *>
		readonly property color {{name}}: "{{value.default.hex}}"
	<* endfor *>
	readonly property color micActive: "#ff9f0a"
}
