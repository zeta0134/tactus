function easeOutBack(x) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    return 1 + c3 * Math.pow(x - 1, 3) + c1 * Math.pow(x - 1, 2);
}

function doEasing(frames, strength, easingFunc) {
    values = []
    for (x = 0; x < frames; x++) {
        values.push(Math.round(easingFunc(x / frames) * strength));
    }    
    return values;
}
