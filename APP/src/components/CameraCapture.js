import React, { useRef, useState } from 'react';
import Webcam from 'react-webcam';
import { Button, Box, Switch } from '@mui/material';

const CameraCapture = () => {
  const webcamRef = useRef(null);
  const [capturedImage, setCapturedImage] = useState(null);
  const [isCapturing, setIsCapturing] = useState(false);
  const [facingMode, setFacingMode] = useState('user'); // 'user' for front camera, 'environment' for rear camera

  const handleCaptureStart = () => {
    setIsCapturing(true);
  };

  const handleCaptureStop = () => {
    setIsCapturing(false);
  };

  const handleCapture = () => {
    const imageSrc = webcamRef.current.getScreenshot({
      type: 'image/jpeg',
      quality: 1.0, // Adjust the quality if needed
    });
    setCapturedImage(imageSrc);
    setIsCapturing(false); // Stop live feed after capture
  };

  const handleRecapture = () => {
    setCapturedImage(null); // Clear captured image
    setIsCapturing(true); // Resume live feed for recapture
  };

  const handleUpload = () => {
    // You can implement the upload logic here
    if (capturedImage) {
      console.log('Uploading captured image:', capturedImage);
      // Implement your upload logic (e.g., send the capturedImage to a server)
    }
  };

  const handleSwitchCamera = () => {
    setFacingMode((prevFacingMode) =>
      prevFacingMode === 'user' ? 'environment' : 'user'
    );
  };

  return (
    <Box
      display="flex"
      flexDirection="column"
      alignItems="center"
      justifyContent="center"
      textAlign="center"
      mt={4}
    >
      <h3 className="text-white mb-0">Camera Capture</h3>
      {isCapturing ? (
        <>
          <Webcam
            audio={false}
            ref={webcamRef}
            screenshotFormat="image/jpeg"
            screenshotQuality={1.0} // Adjust the quality if needed
            videoConstraints={{ facingMode }}
            style={{ width: '60%' }}
          />
          <Button variant="contained" color="primary" onClick={handleCapture}>
            Capture
          </Button>
        </>
      ) : (
        <>
          {capturedImage ? (
            <>
              <img
                src={capturedImage}
                alt="Captured Image"
                style={{
                  width: '60%', // Set width to 100% to match the webcam feed
                  height: 'auto', // Maintain aspect ratio
                }}
              />
              <Button
                variant="contained"
                color="primary"
                onClick={handleRecapture}
              >
                Recapture
              </Button>
            </>
          ) : (
            <Button
              variant="contained"
              color="primary"
              onClick={handleCaptureStart}
            >
              Start Live Feed
            </Button>
          )}
        </>
      )}
      <Button variant="contained" color="primary" onClick={handleCaptureStop}>
        Stop Live Feed
      </Button>
      {capturedImage && (
        <>
          <Button
            variant="contained"
            color="primary"
            onClick={handleUpload}
          >
            Upload
          </Button>
        </>
      )}
      <Box mt={2}>
        <label className="text-white mb-0">Switch Camera</label>
        <Switch
          color="primary"
          checked={facingMode === 'user'}
          onChange={handleSwitchCamera}
        />
      </Box>
    </Box>
  );
};

export default CameraCapture;