import fs from 'fs';
import path from 'path';
import { parseSync } from 'svgson';

interface PixelData {
  name: string;
  positions: number[];
}

const convertSvgToPositions = (svgContent: string): number[] => {
  const parsed = parseSync(svgContent);
  const positions: number[] = [];

  const processRect = (rect: any) => {
    const x = parseInt(rect.attributes.x);
    const y = parseInt(rect.attributes.y);
    
    // Extract RGB values from fill color
    const fill = rect.attributes.fill || '#000000';
    const rgb = fill.match(/^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i);
    
    if (rgb) {
      const r = parseInt(rgb[1], 16);
      const g = parseInt(rgb[2], 16); 
      const b = parseInt(rgb[3], 16);
      
      positions.push(x, y, r, g, b);
    }
  };

  const findRects = (node: any) => {
    if (node.name === 'rect') {
      processRect(node);
    }
    if (node.children) {
      node.children.forEach(findRects);
    }
  };

  findRects(parsed);
  return positions;
}

const processSvgFolder = (folderPath: string): PixelData[] => {
  const files = fs.readdirSync(folderPath);
  const results: PixelData[] = [];

  files.forEach((file, index) => {
    if (path.extname(file) === '.svg') {
      const svgContent = fs.readFileSync(path.join(folderPath, file), 'utf-8');
      const positions = convertSvgToPositions(svgContent);
      
      results.push({
        name: `${path.basename(folderPath)}_${String(index + 1).padStart(2, '0')}`,
        positions
      });
    }
  });

  return results;
}

const convertAssetsToJson = (assetsPath: string) => {
  const folders = fs.readdirSync(assetsPath, { withFileTypes: true })
    .filter(dirent => dirent.isDirectory())
    .map(dirent => dirent.name);

  const allData: {[key: string]: PixelData[]} = {};

  folders.forEach(folder => {
    const folderPath = path.join(assetsPath, folder);
    allData[folder] = processSvgFolder(folderPath);
  });

  return allData;
}

export const migrateData = (assetsPath: string, outputPath: string) => {
  const data = convertAssetsToJson(assetsPath);
  fs.writeFileSync(outputPath, JSON.stringify(data, null, 2));
}
