
export function encodeToBinary(data: [number, number, string][]): Uint8Array {
    // Calculate total bytes needed: 2 bytes per coordinate + 3 bytes per color (RGB)
    const totalBytes = data.length * (2 + 3);
    const bytes = new Uint8Array(totalBytes);
    
    let byteIndex = 0;
    for (const [x, y, color] of data) {
        // Write x,y coordinates (1 byte each)
        bytes[byteIndex++] = x;
        bytes[byteIndex++] = y;
        
        // Convert hex color to RGB bytes
        const r = parseInt(color.slice(1,3), 16);
        const g = parseInt(color.slice(3,5), 16);
        const b = parseInt(color.slice(5,7), 16);
        
        // Write RGB values
        bytes[byteIndex++] = r;
        bytes[byteIndex++] = g;
        bytes[byteIndex++] = b;
    }
    
    // Save to .txt file
    const textEncoder = new TextEncoder();
    const textData = Array.from(bytes).join(',');
    const encodedData = textEncoder.encode(textData);
    
    // Create blob and trigger download
    const blob = new Blob([encodedData], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'binary_data.txt';
    a.click();
    URL.revokeObjectURL(url);
    
    return bytes;
}

export function decodeBinary(bytes: Uint8Array): [number, number, string][] {
    const data: [number, number, string][] = [];
    
    // Process bytes in groups of 5 (2 for coords, 3 for RGB)
    for (let i = 0; i < bytes.length; i += 5) {
        const x = bytes[i];
        const y = bytes[i + 1];
        const r = bytes[i + 2];
        const g = bytes[i + 3]; 
        const b = bytes[i + 4];
        
        // Convert RGB values to hex color string
        const color = '#' + [r, g, b].map(n => {
            const hex = n.toString(16);
            return hex.length === 1 ? '0' + hex : hex;
        }).join('');
        
        data.push([x, y, color]);
    }
    
    return data;
}

export function renderSVG(data: [number, number, string][]): string {
    // Create SVG container with viewBox
    let svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">`;
    
    // Generate rect elements for each pixel
    for (const [x, y, color] of data) {
        svg += `
            <rect 
                x="${x}" 
                y="${y}" 
                width="1" 
                height="1" 
                fill="${color}"
            />`;
    }
    
    svg += '</svg>';
    return svg;
}

export function decodeAndRender(bytes: Uint8Array): string {
    const data = decodeBinary(bytes);
    return renderSVG(data);
}



export const varCont = [
    [11, 4, "#F42020"],
    [12, 4, "#F42020"],
    [13, 4, "#F42020"],
    [11, 5, "#F42020"],
    [12, 5, "#F42020"],
    [13, 5, "#F42020"],
    [12, 6, "#000000"],
    [12, 7, "#000000"],
    [4, 8, "#000000"],
    [5, 8, "#000000"],
    [6, 8, "#000000"],
    [7, 8, "#000000"],
    [8, 8, "#000000"],
    [9, 8, "#000000"],
    [10, 8, "#000000"],
    [11, 8, "#000000"],
    [12, 8, "#000000"],
    [13, 8, "#000000"],
    [14, 8, "#000000"],
    [15, 8, "#000000"],
    [16, 8, "#000000"],
    [17, 8, "#000000"],
    [18, 8, "#000000"],
    [19, 8, "#000000"],
    [4, 9, "#000000"],
    [5, 9, "#639BFF"],
    [6, 9, "#639BFF"],
    [7, 9, "#639BFF"],
    [8, 9, "#639BFF"],
    [9, 9, "#639BFF"],
    [10, 9, "#639BFF"],
    [11, 9, "#639BFF"],
    [12, 9, "#639BFF"],
    [13, 9, "#639BFF"],
    [14, 9, "#639BFF"],
    [15, 9, "#639BFF"],
    [16, 9, "#639BFF"],
    [17, 9, "#639BFF"],
    [18, 9, "#639BFF"],
    [19, 9, "#000000"],
    [4, 10, "#000000"],
    [5, 10, "#639BFF"],
    [6, 10, "#639BFF"],
    [7, 10, "#639BFF"],
    [8, 10, "#639BFF"],
    [9, 10, "#639BFF"],
    [10, 10, "#639BFF"],
    [11, 10, "#639BFF"],
    [12, 10, "#639BFF"],
    [13, 10, "#639BFF"],
    [14, 10, "#639BFF"],
    [15, 10, "#639BFF"],
    [16, 10, "#639BFF"],
    [17, 10, "#639BFF"],
    [18, 10, "#639BFF"],
    [19, 10, "#000000"],
    [4, 11, "#000000"],
    [5, 11, "#639BFF"],
    [6, 11, "#639BFF"],
    [7, 11, "#639BFF"],
    [8, 11, "#639BFF"],
    [9, 11, "#639BFF"],
    [10, 11, "#639BFF"],
    [11, 11, "#639BFF"],
    [12, 11, "#639BFF"],
    [13, 11, "#639BFF"],
    [14, 11, "#639BFF"],
    [15, 11, "#639BFF"],
    [16, 11, "#639BFF"],
    [17, 11, "#639BFF"],
    [18, 11, "#639BFF"],
    [19, 11, "#000000"],
    [4, 12, "#000000"],
    [5, 12, "#639BFF"],
    [6, 12, "#639BFF"],
    [7, 12, "#639BFF"],
    [8, 12, "#639BFF"],
    [9, 12, "#639BFF"],
    [10, 12, "#639BFF"],
    [11, 12, "#639BFF"],
    [12, 12, "#639BFF"],
    [13, 12, "#639BFF"],
    [14, 12, "#639BFF"],
    [15, 12, "#639BFF"],
    [16, 12, "#639BFF"],
    [17, 12, "#639BFF"],
    [18, 12, "#639BFF"],
    [19, 12, "#000000"],
    [4, 13, "#000000"],
    [5, 13, "#639BFF"],
    [6, 13, "#639BFF"],
    [7, 13, "#639BFF"],
    [8, 13, "#639BFF"],
    [9, 13, "#639BFF"],
    [10, 13, "#639BFF"],
    [11, 13, "#639BFF"],
    [12, 13, "#639BFF"],
    [13, 13, "#639BFF"],
    [14, 13, "#639BFF"],
    [15, 13, "#639BFF"],
    [16, 13, "#639BFF"],
    [17, 13, "#639BFF"],
    [18, 13, "#639BFF"],
    [19, 13, "#000000"],
    [4, 14, "#000000"],
    [5, 14, "#639BFF"],
    [6, 14, "#639BFF"],
    [7, 14, "#639BFF"],
    [8, 14, "#639BFF"],
    [9, 14, "#639BFF"],
    [10, 14, "#639BFF"],
    [11, 14, "#639BFF"],
    [12, 14, "#639BFF"],
    [13, 14, "#639BFF"],
    [14, 14, "#639BFF"],
    [15, 14, "#639BFF"],
    [16, 14, "#639BFF"],
    [17, 14, "#639BFF"],
    [18, 14, "#639BFF"],
    [19, 14, "#000000"],
    [4, 15, "#000000"],
    [5, 15, "#639BFF"],
    [6, 15, "#639BFF"],
    [7, 15, "#639BFF"],
    [8, 15, "#639BFF"],
    [9, 15, "#639BFF"],
    [10, 15, "#639BFF"],
    [11, 15, "#639BFF"],
    [12, 15, "#639BFF"],
    [13, 15, "#639BFF"],
    [14, 15, "#639BFF"],
    [15, 15, "#639BFF"],
    [16, 15, "#639BFF"],
    [17, 15, "#639BFF"],
    [18, 15, "#639BFF"],
    [19, 15, "#000000"],
    [4, 16, "#000000"],
    [5, 16, "#639BFF"],
    [6, 16, "#639BFF"],
    [7, 16, "#639BFF"],
    [8, 16, "#639BFF"],
    [9, 16, "#639BFF"],
    [10, 16, "#639BFF"],
    [11, 16, "#639BFF"],
    [12, 16, "#639BFF"],
    [13, 16, "#639BFF"],
    [14, 16, "#639BFF"],
    [15, 16, "#639BFF"],
    [16, 16, "#639BFF"],
    [17, 16, "#639BFF"],
    [18, 16, "#639BFF"],
    [19, 16, "#000000"],
    [4, 17, "#000000"],
    [5, 17, "#000000"],
    [6, 17, "#000000"],
    [7, 17, "#000000"],
    [8, 17, "#000000"],
    [9, 17, "#000000"],
    [10, 17, "#000000"],
    [11, 17, "#000000"],
    [12, 17, "#000000"],
    [13, 17, "#000000"],
    [14, 17, "#000000"],
    [15, 17, "#000000"],
    [16, 17, "#000000"],
    [17, 17, "#000000"],
    [18, 17, "#000000"],
    [19, 17, "#000000"],
    [10, 18, "#000000"],
    [11, 18, "#639BFF"],
    [12, 18, "#639BFF"],
    [13, 18, "#000000"],
    [3, 19, "#000000"],
    [6, 19, "#000000"],
    [10, 19, "#000000"],
    [11, 19, "#639BFF"],
    [12, 19, "#639BFF"],
    [13, 19, "#000000"],
    [17, 19, "#000000"],
    [20, 19, "#000000"],
    [3, 20, "#000000"],
    [4, 20, "#000000"],
    [5, 20, "#000000"],
    [6, 20, "#000000"],
    [9, 20, "#000000"],
    [10, 20, "#639BFF"],
    [11, 20, "#639BFF"],
    [12, 20, "#639BFF"],
    [13, 20, "#639BFF"],
    [14, 20, "#000000"],
    [17, 20, "#000000"],
    [18, 20, "#000000"],
    [19, 20, "#000000"],
    [20, 20, "#000000"],
    [5, 21, "#639BFF"],
    [8, 21, "#000000"],
    [9, 21, "#639BFF"],
    [10, 21, "#639BFF"],
    [11, 21, "#639BFF"],
    [12, 21, "#639BFF"],
    [13, 21, "#639BFF"],
    [14, 21, "#639BFF"],
    [15, 21, "#000000"],
    [18, 21, "#639BFF"],
    [5, 22, "#639BFF"],
    [7, 22, "#000000"],
    [8, 22, "#639BFF"],
    [9, 22, "#639BFF"],
    [10, 22, "#639BFF"],
    [11, 22, "#639BFF"],
    [12, 22, "#639BFF"],
    [13, 22, "#639BFF"],
    [14, 22, "#639BFF"],
    [15, 22, "#639BFF"],
    [16, 22, "#000000"],
    [18, 22, "#639BFF"],
    [5, 23, "#639BFF"],
    [6, 23, "#000000"],
    [7, 23, "#639BFF"],
    [8, 23, "#639BFF"],
    [9, 23, "#639BFF"],
    [10, 23, "#639BFF"],
    [11, 23, "#639BFF"],
    [12, 23, "#639BFF"],
    [13, 23, "#639BFF"],
    [14, 23, "#639BFF"],
    [15, 23, "#639BFF"],
    [16, 23, "#639BFF"],
    [17, 23, "#000000"],
    [18, 23, "#639BFF"]
];


