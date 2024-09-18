export function swap(x, y, chars) {
    [chars.buffer[x], chars.buffer[y]] = [chars.buffer[y], chars.buffer[x]];
    return chars;
}

export function is_number_encodable(n) {
    return n > 0 && n <= Number.MAX_SAFE_INTEGER;
}
