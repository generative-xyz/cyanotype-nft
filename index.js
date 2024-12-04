function encodeSvgToBytes(svgString) {
    // Encode the SVG string to UTF-8 bytes
    const encoder = new TextEncoder();
    const utf8Bytes = encoder.encode(svgString);

    // If you need it in a different format like Uint8Array or just an array of numbers:
    return Array.from(utf8Bytes);
}

// Example usage:
const svgString = '<svg width="100" height="100"><rect width="100" height="100" fill="red"/></svg>';
const byteArray = encodeSvgToBytes(svgString);
console.log(byteArray);
