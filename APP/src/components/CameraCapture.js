import React, { useRef, useState } from 'react';
import Webcam from 'react-webcam';
import { Button, Box, Switch } from '@mui/material';
import { postTeamPictures } from 'api';
import { useHistory } from 'react-router-dom/cjs/react-router-dom.min';

const CameraCapture = () => {
  const history = useHistory()
  const webcamRef = useRef(null);
  const url = new URL(window.location.href);
  const eventName = url.pathname.split("/")[3] + url.pathname.split("/")[4];
  const year = url.pathname.split("/")[3]
  const eventCode = url.pathname.split("/")[4]
  const team = url.pathname.split("/")[5]
  const [capturedImage, setCapturedImage] = useState(null);
  const [isCapturing, setIsCapturing] = useState(true);
  const [facingMode, setFacingMode] = useState('user'); // 'user' for front camera, 'environment' for rear camera
  const [show, setShow] = useState(true)
  const [status, setStatus] = useState("Upload Failed")

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
    if (status === 200){
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

  const handleSwitchCamera = () => {
    setFacingMode((prevFacingMode) =>
      prevFacingMode === 'user' ? 'environment' : 'user'
    );
  };
  
  const backToScouting = () => {
    history.push(`../../../event/${year}/${eventCode}#pit-scouting`);
  }

  const addAnotherPicture = () => {
    setShow(true)
    setCapturedImage(null)
    setIsCapturing(true)
  }

  return (
    <>
    {show && <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', padding: '16px'}}>
      <h3 className="text-white mb-0">Camera Capture</h3>
      {isCapturing ? (
        <>
          <Webcam
            audio={false}
            ref={webcamRef}
            screenshotFormat="image/jpeg"
            screenshotQuality={1.0} // Adjust the quality if needed
            videoConstraints={{ facingMode }}
            style={{ width: '60%', alignSelf: "center"}}
          />
          <Button variant="contained" color="primary" onClick={handleCapture}>
            Capture
          </Button>
        </>
      ) : (
        <>
          {capturedImage &&
            <>
              <img
                src={capturedImage}
                alt="Captured Image"
                style={{
                  width: '60%', // Set width to 100% to match the webcam feed
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
      <Box mt={2}>
        <label className="text-white mb-0">Switch Camera</label>
        <Switch
          color="primary"
          checked={facingMode === 'user'}
          onChange={handleSwitchCamera}
        />
      </Box>
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
