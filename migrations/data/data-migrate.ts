import * as fs from 'fs';
import * as glob from 'glob';
import * as path from 'path';
const { parseSync } = require('svgson');

// Use absolute path to testAssets folder
const PATH_ASSETS = path.join(__dirname, '../assets');
const PATH_OUTPUT = 'migrations/data/datajson/data-compressed.json';

interface PixelData {
  name: string;
  trait: number;
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

const convertAssetsToJson = (assetsPath: string): Record<string, Record<string, any>> => {
  try {
    if (!fs.existsSync(assetsPath)) {
      throw new Error(`Assets directory not found at: ${assetsPath}`);
    }

    const allData: Record<string, Record<string, any>> = {};

    // Use glob to find all SVG files in subdirectories
    const svgFiles = glob.sync(path.join(assetsPath, '**/*.svg'));
    
    svgFiles.forEach((filePath: string) => {
      // Get relative path segments
      const pathSegments = path.relative(assetsPath, filePath).split(path.sep);
      const mainFolder = pathSegments[0]; // First segment is the main folder
      const subFolder = pathSegments[1]; // Second segment is the sub folder
      
      if (!allData[mainFolder]) {
        allData[mainFolder] = {};
      }

      if (mainFolder === 'DNA') {
        // For DNA folder, extract trait from subfolder name
        const [_, subFolderTrait] = subFolder.split('_');
        const folderTrait = parseInt(subFolderTrait);

        if (!allData[mainFolder][subFolder]) {
          // Initialize DNA subfolder with trait and items array
          allData[mainFolder][subFolder] = {
            trait: folderTrait,
            items: []
          };
        }

        const svgContent = fs.readFileSync(filePath, 'utf-8');
        const positions = convertSvgToPositions(svgContent);
        
        // Extract name and trait from individual file
        const [name, traitStr] = path.basename(filePath, '.svg').split('_');
        const trait = traitStr ? parseInt(traitStr) : allData[mainFolder][subFolder].items.length + 1;

        allData[mainFolder][subFolder].items.push({
          name: `${name}_${trait}`,
          trait,
          positions
        });

      } else {
        // For non-DNA folders, keep original structure
        if (!allData[mainFolder][subFolder]) {
          allData[mainFolder][subFolder] = [];
        }

        const svgContent = fs.readFileSync(filePath, 'utf-8');
        const positions = convertSvgToPositions(svgContent);
        
        const [name, traitStr] = path.basename(filePath, '.svg').split('_');
        const trait = traitStr ? parseInt(traitStr) : allData[mainFolder][subFolder].length + 1;

        allData[mainFolder][subFolder].push({
          name: `${name}_${trait}`,
          trait,
          positions
        });
      }
    });
      
    console.log('Data processing complete');
    return allData;

  } catch (err) {
    console.error('Error converting assets:', err);
    process.exit(1);
  }
}

try {
  console.log('Assets path:', PATH_ASSETS);
  console.log('Output path:', PATH_OUTPUT);
  const data = convertAssetsToJson(PATH_ASSETS);
  fs.writeFileSync(PATH_OUTPUT, JSON.stringify(data, null, 2));
  console.log('Successfully wrote data to', PATH_OUTPUT);
} catch (err) {
  console.error('Fatal error:', err);
  process.exit(1);
}