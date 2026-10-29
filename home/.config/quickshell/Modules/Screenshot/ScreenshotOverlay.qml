pragma ComponentBehavior: Bound

import Quickshell
import qs.Services

Variants {
    model: ScreenshotSession.overlayVisible ? Quickshell.screens : []

    delegate: ScreenshotOverlayWindow {}
}
