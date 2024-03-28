import React, { useEffect, useRef, useState } from 'react';
import Webcam from 'react-webcam';
import { Button, Box, Switch } from '@mui/material';
import { postTeamPictures } from 'api';
import { useHistory } from 'react-router-dom/cjs/react-router-dom.min';

const CameraCapture = () => {
  const history = useHistory()
  const webcamRef = useRef(null);
  const url = new URL(window.location.href);
  const year = url.pathname.split("/")[3]
  const eventCode = url.pathname.split("/")[4]
  const team = url.pathname.split("/")[5]
  const [capturedImage, setCapturedImage] = useState(null);
  const [isCapturing, setIsCapturing] = useState(true);
  const [facingMode, setFacingMode] = useState('user'); // 'user' for front camera, 'environment' for rear camera
  const [show, setShow] = useState(true)
  const [status, setStatus] = useState("Upload Failed")

  // useEffect (()=>{
  //   console.log(capturedImage)
  // }, [capturedImage])
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

  const uploadStatusCallback = (status) => {
    if (status === 200) {
      setShow(false)
      setStatus("Image Uploaded Successfully")
    } else {
      setShow(false)
      setStatus("Upload Failed")
    }
  }

  const handleUpload = () => {
    postTeamPictures(year, eventCode, team, capturedImage, uploadStatusCallback)
  };

  const backToScouting = () => {
    history.push(`../../../event/${year}/${eventCode}#pit-scouting`);
  }

  const addAnotherPicture = () => {
    setShow(true)
    setCapturedImage(null)
    setIsCapturing(true)
  }

  const handleFileSelect = (event) => {
    const file = event.target.files[0];
    console.log(file)
    if (file) {
      const reader = new FileReader();
      reader.onload = () => {
        setCapturedImage(reader.result);
        setIsCapturing(false)
      };
      reader.readAsDataURL(file);
    }
  };

  return (
    <>
      {show && <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', padding: '16px' }}>
        <h3 className="text-white mb-0">Camera Capture</h3>
        {isCapturing ? (
          <>
            <div>
              <input
                type="file"
                accept="image/*"
                capture="environment"
                onChange={handleFileSelect}
                style={{ display: 'none' }} // Hide the input element
                id="image-input"
              />
              <label htmlFor="image-input">
                <Button fullWidth variant="contained" component="span">
                  Capture Image
                </Button>
              </label>
            </div>
          </>
        ) : (
          <>
            {capturedImage &&
              <>
                <img
                  src={capturedImage}
                  alt="Captured Image"
                  style={{
                    width: '100%', // Set width to 100% to match the webcam feed
                    height: 'auto', // Maintain aspect ratio
                    alignSelf: "center"
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
            }
          </>
        )}
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
      </div>}
      {(!show) &&
        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', padding: '16px' }}>
          <h1 className="text-white mb-0">{status}</h1>
          <Button variant="contained" color="primary" onClick={backToScouting}>
            Back To Scouting
          </Button>
          <Button variant="contained" color="primary" onClick={addAnotherPicture}>
            Add Another Picture
          </Button>
        </div>
      }
    </>
  );
};

export default CameraCapture;
