import React, { useState, useRef, useEffect } from 'react';
import Button from '@mui/material/Button';
import Box from '@mui/material/Box';
import { CompactPicker } from 'react-color';

const DEFAULT_LINE_WIDTH = 10;

const DrawingCanvas = ({ backgroundImageSrc }) => {
  const canvasContainerRef = useRef(null); // Reference to the canvas container
  const canvasRef = useRef(null);
  const [isDrawing, setIsDrawing] = useState(false);
  const [lines, setLines] = useState([]);
  const [currentLine, setCurrentLine] = useState({ points: [], color: '#000' }); // Include color in currentLine state
  const [isImageLoaded, setIsImageLoaded] = useState(false); // Track if the background image is loaded

  useEffect(() => {
    const canvas = canvasRef.current;
    const context = canvas.getContext('2d');
    context.lineWidth = DEFAULT_LINE_WIDTH;

    const image = new Image();
    image.src = backgroundImageSrc;
    image.onload = () => {
      setIsImageLoaded(true);
      redrawBackgroundImage(image);
    };

    // Prevent scrolling when drawing on touch devices
    canvas.addEventListener('touchmove', handleTouchMove, { passive: false });

    return () => {
      canvas.removeEventListener('touchmove', handleTouchMove);
    };
  }, [backgroundImageSrc]);

  const handleTouchMove = (event) => {
    event.preventDefault();
  };

  const startDrawing = (event) => {
    if (!isImageLoaded) return;
    const { clientX, clientY } = event.touches ? event.touches[0] : event;
    const { offsetX, offsetY } = getCanvasOffset(clientX, clientY);
    setIsDrawing(true);
    setCurrentLine({ points: [{ x: offsetX, y: offsetY }], color: currentLine.color }); // Preserve color
  };

  const draw = (event) => {
    if (!isImageLoaded) return;
    const { clientX, clientY } = event.touches ? event.touches[0] : event;
    const { offsetX, offsetY } = getCanvasOffset(clientX, clientY);

    if (isDrawing) {
      setCurrentLine((prevLine) => ({
        ...prevLine,
        points: [...prevLine.points, { x: offsetX, y: offsetY }],
      }));
      
      // Introduce a delay before redrawing the canvas
      setTimeout(() => {
        redrawCanvas([...lines, currentLine], currentLine.color); // Redraw canvas with the current line and existing lines, maintaining color
      }, 10); // Adjust the delay duration as needed
    }
  };

  const endDrawing = () => {
    if (!isDrawing) return;
    setIsDrawing(false);
    setLines([...lines, currentLine]);
    setCurrentLine({ points: [], color: currentLine.color }); // Clear current line after drawing
  };

  const clearCanvas = () => {
    const canvas = canvasRef.current;
    const context = canvas.getContext('2d');
    context.clearRect(0, 0, canvas.width, canvas.height);
    if (isImageLoaded) {
      const image = new Image();
      image.src = backgroundImageSrc;
      image.onload = () => {
        redrawBackgroundImage(image);
      };
    }
    setLines([]);
    setCurrentLine({ points: [], color: '#000' }); // Reset current line color to default
  };

  const undoDrawing = () => {
    setLines(lines.slice(0, -1));
    redrawCanvas(lines.slice(0, -1)); // Redraw canvas with the updated lines
  };

  const redrawCanvas = (updatedLines = lines, color = '#000') => {
    const canvas = canvasRef.current;
    const context = canvas.getContext('2d');

    context.clearRect(0, 0, canvas.width, canvas.height);
    if (isImageLoaded) {
      const image = new Image();
      image.src = backgroundImageSrc;
      image.onload = () => {
        redrawBackgroundImage(image);
        updatedLines.forEach((line) => {
          context.strokeStyle = line.color;
          context.lineWidth = DEFAULT_LINE_WIDTH;
          context.lineCap = 'round';
          context.beginPath();
          context.moveTo(line.points[0].x, line.points[0].y);
          line.points.forEach(({ x, y }) => {
            context.lineTo(x, y);
          });
          context.stroke();
        });
      };
    }
  };

  const redrawBackgroundImage = (image) => {
    try {
      const canvas = canvasRef.current;
      const context = canvas.getContext('2d');
      const aspectRatio = image.width / image.height;
      const parentWidth = canvasContainerRef.current.clientWidth; // Use container width
      const parentHeight = canvasContainerRef.current.clientHeight; // Use container height
      const canvasWidth = Math.min(parentWidth, parentHeight * aspectRatio);
      const canvasHeight = canvasWidth / aspectRatio;
      canvas.width = canvasWidth;
      canvas.height = canvasHeight;
      context.drawImage(image, 0, 0, canvasWidth, canvasHeight);
    } catch {};
  };

  const handleColorChange = (color) => {
    setCurrentLine((prevLine) => ({
      ...prevLine,
      color: color.hex, // Update color of current line
    }));
  };

  const getCanvasOffset = (clientX, clientY) => {
    const canvas = canvasRef.current;
    const { left, top } = canvas.getBoundingClientRect();
    const scaleX = canvas.width / canvas.offsetWidth;
    const scaleY = canvas.height / canvas.offsetHeight;
    return {
      offsetX: (clientX - left) * scaleX,
      offsetY: (clientY - top) * scaleY,
    };
  };

  return (
    <Box display="flex" flexDirection="column" alignItems="center">
      <Box mb={2}>
        <CompactPicker color={currentLine.color} onChangeComplete={handleColorChange} /> {/* Pass current line color */}
      </Box>
      <Button onClick={clearCanvas} variant="contained" color="secondary">Clear Canvas</Button>
      <Button onClick={undoDrawing} variant="contained" color="primary">Undo</Button>
      <Box mb={2} ref={canvasContainerRef} style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', width: '100%', height: '80vh' }}>
        <canvas
          ref={canvasRef}
          onMouseDown={startDrawing}
          onMouseMove={draw}
          onMouseUp={endDrawing}
          onMouseOut={endDrawing}
          onTouchStart={startDrawing}
          onTouchMove={draw}
          onTouchEnd={endDrawing}
          style={{ maxWidth: '100%', maxHeight: '70vh', margin: 'auto', border: '1px solid black' }}
        />
      </Box>
    </Box>
  );
};

export default DrawingCanvas;
