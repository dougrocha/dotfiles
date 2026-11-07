.pragma library

function clamp(value, low, high) {
    return Math.max(low, Math.min(high, value));
}
