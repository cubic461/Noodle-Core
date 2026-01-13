const fs = require('fs');

// Simple 1x1 blue PNG with base64 encoding
const pngBase64 = 'iVBORw0KGgoAAAANSUhEUgAAIAAAgCAYAAAGQGAAABAAAGQAAAD8AAAECAAAAAAAAKGAAABwAAAACAAAAAgAAAAAAAJmZmZmAAAJmZmZmQAAAACAAAABJRU5ErkJggg==';

// Write the base64 data as a binary PNG file
const pngBuffer = Buffer.from(pngBase64, 'base64');

// Write to file
fs.writeFileSync('resources/noodle-icon.png', pngBuffer);

console.log('Created noodle-icon.png successfully');