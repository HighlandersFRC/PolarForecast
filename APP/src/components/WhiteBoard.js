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
  const [prevPos, setPrevPos] = useState({ x: 0, y: 0 });
  const [lineColor, setLineColor] = useState('#000'); // Initial color black
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
    setPrevPos({ x: offsetX, y: offsetY });
  };

  const draw = (event) => {
    if (!isImageLoaded || !isDrawing) return;
    const { clientX, clientY } = event.touches ? event.touches[0] : event;
    const { offsetX, offsetY } = getCanvasOffset(clientX, clientY);
    const canvas = canvasRef.current;
    const context = canvas.getContext('2d');

    context.strokeStyle = lineColor;
    context.lineWidth = DEFAULT_LINE_WIDTH;
    context.lineCap = 'round';
    context.beginPath();
    context.moveTo(prevPos.x, prevPos.y);
    context.lineTo(offsetX, offsetY);
    context.stroke();

    setLines([...lines, { start: prevPos, end: { x: offsetX, y: offsetY }, color: lineColor }]);
    setPrevPos({ x: offsetX, y: offsetY });
  };

  const endDrawing = () => {
    setIsDrawing(false);
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
  };

  const redrawBackgroundImage = (image) => {
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
  };

  const handleColorChange = (color) => {
    setLineColor(color.hex);
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
        <CompactPicker color={lineColor} onChangeComplete={handleColorChange} />
      </Box>
      <Button onClick={clearCanvas} variant="contained" color="secondary">Clear Canvas</Button>
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
