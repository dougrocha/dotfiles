.pragma library

const minimumSide = 2;
const dragThreshold = 3;
const edgeHit = 10;
const toolbarBottomGap = 52;
const optionsGap = 8;
const unfocusedOrder = 9999;

function isSelection(rect) {
    return rect.width >= minimumSide && rect.height >= minimumSide;
}

function normalizedRect(rect) {
    const finite = value => Number.isFinite(value) ? value : 0;
    return {
        x: finite(rect.x),
        y: finite(rect.y),
        width: Math.max(0, finite(rect.width)),
        height: Math.max(0, finite(rect.height))
    };
}

function desktopBounds(screens) {
    if (screens.length === 0)
        return {
            left: 0,
            top: 0,
            right: 0,
            bottom: 0,
            width: 0,
            height: 0
        };
    let left = screens[0].x;
    let top = screens[0].y;
    let right = screens[0].x + screens[0].width;
    let bottom = screens[0].y + screens[0].height;
    for (let i = 1; i < screens.length; ++i) {
        left = Math.min(left, screens[i].x);
        top = Math.min(top, screens[i].y);
        right = Math.max(right, screens[i].x + screens[i].width);
        bottom = Math.max(bottom, screens[i].y + screens[i].height);
    }
    return {
        left: left,
        top: top,
        right: right,
        bottom: bottom,
        width: right - left,
        height: bottom - top
    };
}

function clampToDesktop(desktop, x, y) {
    return {
        x: Math.max(desktop.left, Math.min(desktop.right, x)),
        y: Math.max(desktop.top, Math.min(desktop.bottom, y))
    };
}

function insideDesktop(desktop, x, y) {
    const bounded = clampToDesktop(desktop, x, y);
    return {
        x: bounded.x >= desktop.right ? desktop.right - 0.001 : bounded.x,
        y: bounded.y >= desktop.bottom ? desktop.bottom - 0.001 : bounded.y
    };
}

function pastDragThreshold(drag, x, y) {
    return Math.hypot(x - drag.startX, y - drag.startY) >= dragThreshold;
}

function rectFromPoints(ax, ay, bx, by) {
    return {
        x: Math.min(ax, bx),
        y: Math.min(ay, by),
        width: Math.abs(bx - ax),
        height: Math.abs(by - ay)
    };
}

function movedRect(initial, dx, dy, desktop) {
    return {
        x: Math.max(desktop.left, Math.min(desktop.right - initial.width, initial.x + dx)),
        y: Math.max(desktop.top, Math.min(desktop.bottom - initial.height, initial.y + dy)),
        width: initial.width,
        height: initial.height
    };
}

function resizedRect(initial, horizontal, vertical, x, y) {
    let left = initial.x;
    let right = initial.x + initial.width;
    let top = initial.y;
    let bottom = initial.y + initial.height;
    if (horizontal < 0)
        left = x;
    else if (horizontal > 0)
        right = x;
    if (vertical < 0)
        top = y;
    else if (vertical > 0)
        bottom = y;
    return rectFromPoints(left, top, right, bottom);
}

function containsRect(outer, inner) {
    return inner.x >= outer.x && inner.y >= outer.y && inner.x + inner.width <= outer.x + outer.width && inner.y + inner.height <= outer.y + outer.height;
}

function containsPoint(rect, x, y) {
    return x >= rect.x && x < rect.x + rect.width && y >= rect.y && y < rect.y + rect.height;
}

function hitTest(selection, hasSelection, x, y) {
    const create = {
        kind: "create",
        horizontal: 0,
        vertical: 0
    };
    if (!hasSelection)
        return create;
    const left = selection.x;
    const right = left + selection.width;
    const top = selection.y;
    const bottom = top + selection.height;
    const withinX = x >= left - edgeHit && x <= right + edgeHit;
    const withinY = y >= top - edgeHit && y <= bottom + edgeHit;
    const near = (value, edge) => Math.abs(value - edge) <= edgeHit;
    const horizontal = withinY && near(x, left) ? -1 : withinY && near(x, right) ? 1 : 0;
    const vertical = withinX && near(y, top) ? -1 : withinX && near(y, bottom) ? 1 : 0;
    if (horizontal !== 0 || vertical !== 0)
        return {
            kind: "resize",
            horizontal: horizontal,
            vertical: vertical
        };
    if (x > left && x < right && y > top && y < bottom)
        return {
            kind: "move",
            horizontal: 0,
            vertical: 0
        };
    return create;
}

function resolvedResizeSign(pointer, sign, start, extent) {
    if (sign < 0)
        return pointer <= start + extent ? -1 : 1;
    if (sign > 0)
        return pointer >= start ? 1 : -1;
    return 0;
}

function readoutDirection(drag, selection, x, y) {
    if (drag.kind === "create")
        return {
            directionX: x < drag.startX ? -1 : 1,
            directionY: y < drag.startY ? -1 : 1,
            edgeAxis: "none"
        };
    const axis = (pointer, sign, start, extent, selectionStart, selectionExtent) => {
        const resolved = resolvedResizeSign(pointer, sign, start, extent);
        return resolved !== 0 ? resolved : pointer < selectionStart + selectionExtent / 2 ? -1 : 1;
    };
    return {
        directionX: axis(x, drag.horizontal, drag.initial.x, drag.initial.width, selection.x, selection.width),
        directionY: axis(y, drag.vertical, drag.initial.y, drag.initial.height, selection.y, selection.height),
        edgeAxis: drag.horizontal !== 0 && drag.vertical === 0 ? "horizontal" : drag.vertical !== 0 && drag.horizontal === 0 ? "vertical" : "none"
    };
}

function screenAt(screens, x, y) {
    return screens.find(screen => containsPoint(screen, x, y)) ?? null;
}

function nearestScreen(screens, x, y) {
    const inside = screenAt(screens, x, y);
    if (inside)
        return inside.name;
    let nearest = "";
    let nearestDistance = Infinity;
    for (const screen of screens) {
        const dx = Math.max(screen.x - x, 0, x - screen.x - screen.width);
        const dy = Math.max(screen.y - y, 0, y - screen.y - screen.height);
        const distance = dx * dx + dy * dy;
        if (distance < nearestDistance) {
            nearest = screen.name;
            nearestDistance = distance;
        }
    }
    return nearest;
}

function visibleWindows(toplevels, monitors) {
    const workspaceIds = monitors.map(monitor => {
        const data = monitor.lastIpcObject;
        const specialId = data?.specialWorkspace?.id ?? 0;
        return specialId !== 0 ? specialId : data?.activeWorkspace?.id ?? monitor.activeWorkspace?.id;
    });
    const mapped = toplevels.filter(toplevel => {
        const data = toplevel.lastIpcObject;
        return data != null && data.mapped !== false && !data.hidden && workspaceIds.includes(data.workspace?.id);
    });
    const fullscreenWorkspaceIds = mapped.filter(toplevel => toplevel.lastIpcObject.fullscreen !== 0).map(toplevel => toplevel.lastIpcObject.workspace.id);
    return mapped.filter(toplevel => !fullscreenWorkspaceIds.includes(toplevel.lastIpcObject.workspace.id) || toplevel.lastIpcObject.fullscreen !== 0).sort((a, b) => (a.lastIpcObject.focusHistoryID ?? unfocusedOrder) - (b.lastIpcObject.focusHistoryID ?? unfocusedOrder)).map(toplevel => ({
                address: toplevel.address,
                x: toplevel.lastIpcObject.at[0],
                y: toplevel.lastIpcObject.at[1],
                width: toplevel.lastIpcObject.size[0],
                height: toplevel.lastIpcObject.size[1]
            }));
}

function windowAt(windows, x, y) {
    return windows.find(window => containsPoint(window, x, y)) ?? null;
}

function geometryString(rect) {
    return Math.round(rect.x) + "," + Math.round(rect.y) + " " + Math.round(rect.width) + "x" + Math.round(rect.height);
}

function toOutput(rect, screen) {
    return {
        x: rect.x - screen.x,
        y: rect.y - screen.y,
        width: rect.width,
        height: rect.height
    };
}

function fromOutput(rect, screen) {
    return {
        x: screen.x + rect.x,
        y: screen.y + rect.y,
        width: rect.width,
        height: rect.height
    };
}

function isSavedRegion(region, screen) {
    if (region == null || screen == null)
        return false;
    if (!Number.isFinite(region.x) || !Number.isFinite(region.y) || !Number.isFinite(region.width) || !Number.isFinite(region.height))
        return false;
    if (!isSelection(region) || region.x < 0 || region.y < 0)
        return false;
    return region.x + region.width <= screen.width && region.y + region.height <= screen.height;
}

function isSavedToolbar(position) {
    return position != null && Number.isFinite(position.x) && Number.isFinite(position.y) && position.x >= 0 && position.y >= 0;
}

function clampToolbar(position, size, screen) {
    return {
        x: position.x >= 0 ? Math.max(0, Math.min(screen.width - size.width, position.x)) : (screen.width - size.width) / 2,
        y: position.y >= 0 ? Math.max(0, Math.min(screen.height - size.height, position.y)) : screen.height - size.height - toolbarBottomGap
    };
}

function optionsPlacement(toolbar, size, screen) {
    const x = Math.max(optionsGap, Math.min(screen.width - size.width - optionsGap, toolbar.x + (toolbar.width - size.width) / 2));
    const y = toolbar.y >= size.height + optionsGap ? toolbar.y - size.height - optionsGap : Math.min(screen.height - size.height - optionsGap, toolbar.y + toolbar.height + optionsGap);
    return {
        x: x,
        y: y
    };
}

function normalizedDirectory(path) {
    return path.replace(/\/+$/, "");
}

function directoryLabel(path, defaultDirectory) {
    const segments = value => value.split("/").filter(part => part !== "");
    if (path === "") {
        const parts = segments(defaultDirectory);
        return parts.length > 0 ? parts.slice(-2).join("/") : "Pictures/Screenshots";
    }
    const parts = segments(path);
    return parts.length > 0 ? parts[parts.length - 1] : path;
}

function pointerFromCursorOutput(text) {
    const coordinates = text.trim().split(",");
    if (coordinates.length !== 2)
        return null;
    const x = Number(coordinates[0]);
    const y = Number(coordinates[1]);
    return Number.isFinite(x) && Number.isFinite(y) ? {
        x: x,
        y: y
    } : null;
}
