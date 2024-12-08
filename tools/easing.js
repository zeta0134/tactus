function easeOutBounce(x) {
    const n1 = 7.5625;
    const d1 = 2.75;

    if (x < 1 / d1) {
        return n1 * x * x;
    } else if (x < 2 / d1) {
        return n1 * (x -= 1.5 / d1) * x + 0.75;
    } else if (x < 2.5 / d1) {
        return n1 * (x -= 2.25 / d1) * x + 0.9375;
    } else {
        return n1 * (x -= 2.625 / d1) * x + 0.984375;
    }
}

function easeOutBack(x) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    return 1 + c3 * Math.pow(x - 1, 3) + c1 * Math.pow(x - 1, 2);
}

function ca65_byte_literal(number) {
    clamped_number = Math.min(255, Math.max(-128, number))
    if (clamped_number < 0) {
        return "<"+clamped_number
    } else {
        return clamped_number
    }
}

function doEasing(frames, strength, easingFunc, offset=0) {
    values = []
    for (x = 0; x < frames; x++) {
        values.push(ca65_byte_literal(Math.round(easingFunc(x / frames) * strength) + offset));
    }
    string_values = ".byte " + values.join(",")
    return string_values;
}



