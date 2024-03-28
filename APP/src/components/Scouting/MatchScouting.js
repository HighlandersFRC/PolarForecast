import React, { useState, useEffect, createRef, useRef } from 'react';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import { getMatchDetails } from 'api';
import { FormControl, FormHelperText, InputLabel, MenuItem, Select, Switch } from '@mui/material';
import { postMatchScouting, putMatchScouting } from 'api';
import { QRCode } from 'react-qrcode-logo';
import { BrowserView, MobileView } from 'react-device-detect';
import Counter from 'components/Counter';

const MatchScouting = ({ defaultEventCode: eventCode = '', year, event }) => {
  const url = new URL(window.location.href);
  const serverPath = url.pathname.split("/")[0];
  const [matchNumber, setMatchNumber] = useState(0)
  const defaultData = {
    event_code: eventCode,
    team_number: 0,
    match_number: 0,
    active: true,
    scout_info: {
      name: "",
    },
    data: {
      auto: {
        amp: 0,
        speaker: 0,
      },
      teleop: {
        amp: 0,
        speaker: 0,
        amped_speaker: 0,
      },
      miscellaneous: {
        died: 0,
        comments: "",
      },
      selectedPieces: [],
    },
    time: 0
  }
  const [formData, setFormData] = useState(defaultData);
  const [showQRCode, setShowQRCode] = useState(false);
  const [showReset, setShowReset] = useState(false);
  const [text, setText] = useState("");
  const [update, setUpdate] = useState(false);
  const [fieldImageWidth, setFieldImageWidth] = useState(0);
  const [imageScaleFactor, setImageScaleFactor] = useState(1);
  const [imageLoaded, setImageLoaded] = useState(false)
  const fieldImageRef = useRef(null);
  const [isFlipped, setIsFlipped] = useState(false);
  const [driverStation, setDriverStation] = useState('');
  const NOTE_SIZE = 80;

  useEffect(() => {
    if (fieldImageRef.current) {
      const { naturalWidth, offsetWidth } = fieldImageRef.current;
      setFieldImageWidth(offsetWidth);
      setImageScaleFactor(offsetWidth / naturalWidth);
    }
  }, [imageLoaded]);

  useEffect(() => {
    if (text === "Unable to Submit.") setText(text + " Use QR Code")
  }, [text]);

  useEffect(() => {
    if (driverStation) {
      if (isFlipped) {
        if (driverStation > 3) flipImage() // Flip the image to match red DS
      } else {
        if (driverStation <= 3) flipImage() // Flip the image to match blue DS
      }
    }
  }, [driverStation])

  useEffect(() => {
    getMatchDetails(year, event, eventCode + "_qm" + String(matchNumber), (data) => matchDataCallback(data.match));
  }, [matchNumber, driverStation])

  useEffect(() => {
    // console.log(formData.data.selectedPieces)
    setMatchNumber(formData.match_number)
  }, [formData])

  const calculatePosition = (x, y) => {
    let scaledX = x * imageScaleFactor;
    let scaledY = y * imageScaleFactor;
    if (isFlipped) {
      scaledX = fieldImageWidth - scaledX - (NOTE_SIZE * imageScaleFactor)
    }
    return { left: `${scaledX}px`, top: `${scaledY}px` };
  };

  // Function to handle piece selection
  const handlePieceClick = (pieceType) => {
    const selectedPieces = [...formData.data.selectedPieces];
    const index = selectedPieces.indexOf(pieceType);
    if (index === -1) {
      selectedPieces.push(pieceType); // If not selected, add it
    } else {
      selectedPieces.splice(index, 1); // If already selected, remove it
    }
    setFormData(prevData => ({
      ...prevData,
      data: {
        ...prevData.data,
        selectedPieces: selectedPieces
      }
    }));
  };

  const handleImageLoad = () => {
    setImageLoaded(true);
  };

  const flipImage = () => {
    setIsFlipped(!isFlipped);
    if (fieldImageRef.current) {
      const image = fieldImageRef.current;
      const scaleX = isFlipped ? 1 : -1; // If isFlipped is true, scaleX is 1 (unflipped), else -1 (flipped)
      image.style.transform = `scaleX(${scaleX})`; // Apply the transformation
      changeBlueToRed(image); // Also apply color changes
    }
  };

  const changeBlueToRed = (image) => {
    const canvas = document.createElement('canvas');
    const context = canvas.getContext('2d');
    canvas.width = image.width;
    canvas.height = image.height;
    context.drawImage(image, 0, 0, image.width, image.height);
    const imageData = context.getImageData(0, 0, canvas.width, canvas.height);
    const data = imageData.data;

    for (let i = 0; i < data.length; i += 4) {
      const red = data[i];
      const green = data[i + 1];
      const blue = data[i + 2];
      if (isFlipped) {
        if (red > 130 && blue < 100 && green < 100) {
          // Change blue pixels to red
          data[i] = blue; // Set red
          data[i + 1] = 0; // Set green
          data[i + 2] = red; // Set blue
        }
      } else {
        if (blue > 130 && red < 100 && green < 100) {
          // Change blue pixels to red
          data[i] = blue; // Set red
          data[i + 1] = 0; // Set green
          data[i + 2] = red; // Set blue
        }
      }
    }
    context.putImageData(imageData, 0, 0);
    image.src = canvas.toDataURL(); // Update the image source with modified data
  };

  // Function to generate JSX for selectable pieces
  const renderSelectablePieces = (formData) => {
    return (
      <>
        <div>
          <div style={{ position: 'relative', maxWidth: '100%', height: 'auto' }}>
            {/* Display your field image here */}
            <img
              ref={fieldImageRef}
              src={serverPath + "/AutosGameField.png"}
              alt="Field"
              style={{ maxWidth: '100%', height: 'auto' }}
              onLoad={handleImageLoad}
            />
            <img
              src="/Note.png"
              style={{
                position: 'absolute',
                ...calculatePosition(186, 978),
                width: `${NOTE_SIZE * imageScaleFactor}px`,
                height: `${NOTE_SIZE * imageScaleFactor}px`,
                cursor: 'pointer',
                filter: formData.data.selectedPieces.includes('spike_left') ? 'none' : 'grayscale(100%)'
              }}
              onClick={() => handlePieceClick('spike_left')}
            />
            <img
              src="/Note.png"
              style={{
                position: 'absolute',
                ...calculatePosition(433, 978),
                width: `${NOTE_SIZE * imageScaleFactor}px`,
                height: `${NOTE_SIZE * imageScaleFactor}px`,
                cursor: 'pointer',
                filter: formData.data.selectedPieces.includes('spike_middle') ? 'none' : 'grayscale(100%)'
              }}
              onClick={() => handlePieceClick('spike_middle')}
            />
            <img
              src="/Note.png"
              style={{
                position: 'absolute',
                ...calculatePosition(679, 978),
                width: `${NOTE_SIZE * imageScaleFactor}px`,
                height: `${NOTE_SIZE * imageScaleFactor}px`,
                cursor: 'pointer',
                filter: formData.data.selectedPieces.includes('spike_right') ? 'none' : 'grayscale(100%)'
              }}
              onClick={() => handlePieceClick('spike_right')}
            />
            <img
              src="/Note.png"
              style={{
                position: 'absolute',
                ...calculatePosition(108, 61),
                width: `${NOTE_SIZE * imageScaleFactor}px`,
                height: `${NOTE_SIZE * imageScaleFactor}px`,
                cursor: 'pointer',
                filter: formData.data.selectedPieces.includes('halfway_far_left') ? 'none' : 'grayscale(100%)'
              }}
              onClick={() => handlePieceClick('halfway_far_left')}
            />
            <img
              src="/Note.png"
              style={{
                position: 'absolute',
                ...calculatePosition(394, 61),
                width: `${NOTE_SIZE * imageScaleFactor}px`,
                height: `${NOTE_SIZE * imageScaleFactor}px`,
                cursor: 'pointer',
                filter: formData.data.selectedPieces.includes('halfway_middle_left') ? 'none' : 'grayscale(100%)'
              }}
              onClick={() => handlePieceClick('halfway_middle_left')}
            />
            <img
              src="/Note.png"
              style={{
                position: 'absolute',
                ...calculatePosition(679, 61),
                width: `${NOTE_SIZE * imageScaleFactor}px`,
                height: `${NOTE_SIZE * imageScaleFactor}px`,
                cursor: 'pointer',
                filter: formData.data.selectedPieces.includes('halfway_middle') ? 'none' : 'grayscale(100%)'
              }}
              onClick={() => handlePieceClick('halfway_middle')}
            />
            <img
              src="/Note.png"
              style={{
                position: 'absolute',
                ...calculatePosition(965, 61),
                width: `${NOTE_SIZE * imageScaleFactor}px`,
                height: `${NOTE_SIZE * imageScaleFactor}px`,
                cursor: 'pointer',
                filter: formData.data.selectedPieces.includes('halfway_middle_right') ? 'none' : 'grayscale(100%)'
              }}
              onClick={() => handlePieceClick('halfway_middle_right')}
            />
            <img
              src="/Note.png"
              style={{
                position: 'absolute',
                ...calculatePosition(1251, 61),
                width: `${NOTE_SIZE * imageScaleFactor}px`,
                height: `${NOTE_SIZE * imageScaleFactor}px`,
                cursor: 'pointer',
                filter: formData.data.selectedPieces.includes('halfway_far_right') ? 'none' : 'grayscale(100%)'
              }}
              onClick={() => handlePieceClick('halfway_far_right')}
            />
          </div>
          <Button variant="contained" fullWidth onClick={flipImage} sx={{ color: isFlipped ? 'blue' : 'red' }}>
            {isFlipped ? 'Flip to Blue' : 'Flip to Red'}
          </Button>
        </div>
      </>
    );
  };

  const matchDataCallback = (data) => {
    // setMatchTeams(data)
    const updatedData = { ...formData };
    let random = Math.floor(Math.random() * 6)
    try {
      if (!driverStation) updatedData.team_number = matchTeams(data)[random].substr(3)
      else updatedData.team_number = matchTeams(data)[driverStation - 1].substr(3)
      updatedData.match_number = data.match_number
      setFormData(updatedData)
    } catch { }
  }

  const handleChange = async (field, value) => {
    if (field === "station") {
      setDriverStation(value)
    } else {
      setFormData((prevData) => {
        const updatedData = { ...prevData };
        const fieldPath = field.split('.');
        let currentField = updatedData;
        for (let i = 0; i < fieldPath.length - 1; i++) {
          currentField = currentField[fieldPath[i]];
        }
        if (field === "scout_info.name" || field === "data.miscellaneous.comments") {
          currentField[fieldPath[fieldPath.length - 1]] = value;
        } else {
          currentField[fieldPath[fieldPath.length - 1]] = Math.max(0, value); // Set minimum value of 0
        }
        return updatedData
      });
      if (field === "match_number") {
        setMatchNumber(value)
      }
    }
  };

  const handleSubmit = () => {
    // Set the "Time" field to the current UTC timestamp when submitting the form
    setFormData((prevData) => ({
      ...prevData,
      time: Math.floor(new Date().getTime() / 1000), // Current UTC timestamp in seconds
    }));
    setText("Submitting...")
    setShowReset(true)
    postMatchScouting(formData, (data) => MatchScoutingStatusCallback(data, false));
  };

  const MatchScoutingStatusCallback = ([status, response], update) => {
    if (!update) {
      if (status === 200) {
        setShowQRCode(false)
        setText("Submission Successful")
      } else if (status === 307) {
        setUpdate(true)
        setShowQRCode(false)
        setText("There is already an entry for this match. Do you want to update it?")
      } else {
        setShowQRCode(true)
        setText(response.detail)
      }
    } else {
      if (status === 200) {
        setShowQRCode(false)
        setUpdate(false)
        setText("Submission Successful")
      } else {
        setShowQRCode(true)
        setText(response.detail)
      }
    }
  }

  const matchTeams = (data) => {
    try {
      let teams = []
      let allianceStr = ""
      for (let i = 0; i < 2; i++) {
        if (i === 0) {
          allianceStr = "red"
        } else if (i === 1) {
          allianceStr = "blue"
        }
        teams = teams.concat(data.alliances[allianceStr].team_keys)
      }
      return teams
    } catch {
      return ["", "", "", "", "", ""]
    }
  }

  const handleReset = () => {
    setShowQRCode(false);
    setShowReset(false);
    setUpdate(false);
    setText('');
    setFormData((prevData) => {
      prevData.match_number += 1;
      prevData.team_number = 0;
      prevData.data = {
        auto: {
          amp: 0,
          speaker: 0,
        },
        teleop: {
          amp: 0,
          speaker: 0,
          amped_speaker: 0,
        },
        miscellaneous: {
          died: false,
          comments: "",
        },
        selectedPieces: [],
      };
      return prevData;
    });
    setMatchNumber(matchNumber + 1);
  };


  const handleUpdate = () => {
    // Set the "Time" field to the current UTC timestamp when submitting the form
    setFormData((prevData) => ({
      ...prevData,
      time: Math.floor(new Date().getTime() / 1000), // Current UTC timestamp in seconds
    }));
    setText("Submitting...")
    setShowReset(true)
    putMatchScouting(formData, (data) => MatchScoutingStatusCallback(data, true));
  };

  return (
    <form style={{ display: 'flex', flexDirection: 'column', gap: '16px', padding: '16px' }}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
        <TextField
          label="Event Code"
          value={formData.event_code}
          onChange={(e) => handleChange('event_code', e.target.value)}
          disabled // Disable the Event Code field
        />
        <TextField
          label="Team Number"
          type="number"
          value={formData.team_number}
          onChange={(e) => handleChange('team_number', Math.min(Math.max(0, parseInt(e.target.value, 10)), 10000))}
          inputProps={{ min: 0 }}
        // disabled // Disable the Team Number field
        />
        <FormControl >
          <InputLabel id="driver-station-label">Driver Station</InputLabel>
          <Select
            label="Driver Station"
            type="number"
            id="driver-station"
            labelId="driver-station-label"
            value={driverStation}
            sx={{color:driverStation ? driverStation<4 ? 'red' : '#1976d2' : ''}}
            onChange={(e) => handleChange('station', e.target.value)}
          >
            <MenuItem value="">
              <em>None</em>
            </MenuItem>
            <MenuItem value={1} sx={{color:'red'}}>R1</MenuItem>
            <MenuItem value={2} sx={{color:'red'}}>R2</MenuItem>
            <MenuItem value={3} sx={{color:'red'}}>R3</MenuItem>
            <MenuItem value={4} sx={{color:'#1976d2'}}>B1</MenuItem>
            <MenuItem value={5} sx={{color:'#1976d2'}}>B2</MenuItem>
            <MenuItem value={6} sx={{color:'#1976d2'}}>B3</MenuItem>
          </Select>
          <FormHelperText>Driver Station Not Required</FormHelperText>
        </FormControl>
        <TextField
          label="Match Number"
          type="number"
          value={formData.match_number}
          onChange={(e) => handleChange('match_number', Math.min(Math.max(0, parseInt(e.target.value, 10)), 1000))}
          inputProps={{ min: 0 }}
        />
        <TextField
          label="Scout Name"
          value={formData.scout_info.name}
          onChange={(e) => handleChange('scout_info.name', e.target.value)}
          inputProps={{ maxLength: 15 }}
        />
      </div>
      <h3 className="text-white mb-0">Select The Pieces That The Robot Controls During Auto</h3>
      {renderSelectablePieces(formData)}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
        <h3 className="text-white mb-0">Auto Fields</h3>
        <Counter
          label="Auto Amp"
          type="number"
          value={formData.data.auto.amp}
          onChange={(value) => handleChange('data.auto.amp', Math.min(Math.max(0, parseInt(value, 10)), 9))}
          max={9}
        />
        <Counter
          label="Auto Speaker"
          type="number"
          value={formData.data.auto.speaker}
          onChange={(value) => handleChange('data.auto.speaker', Math.min(Math.max(0, parseInt(value, 10)), 9))}
          max={9}
        />
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
        <h3 className="text-white mb-0">Teleop Fields</h3>
        {formData && (<>
          <Counter
            label="Teleop Amp"
            type="number"
            value={formData.data.teleop.amp}
            onChange={(value) => handleChange('data.teleop.amp', Math.max(0, parseInt(value, 10)))}
            max={30}
          />
          <Counter
            label="Teleop Speaker"
            type="number"
            value={formData.data.teleop.speaker}
            onChange={(value) => handleChange('data.teleop.speaker', Math.max(0, parseInt(value, 10)))}
            max={30}
          />
          <Counter
            label="Teleop Amplified Speaker"
            type="number"
            value={formData.data.teleop.amped_speaker}
            onChange={(value) => handleChange('data.teleop.amped_speaker', Math.max(0, parseInt(value, 10)))}
            max={30}
          /></>)}
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
        <h3 className="text-white mb-0">Miscellaneous</h3>
        <h4 className="text-white mb-0">Died?</h4>
        <Switch
          label="Died?"
          checked={formData.data.miscellaneous.died}
          onChange={(e) => handleChange('data.miscellaneous.died', e.target.checked)}
          color="warning"
        />
        <TextField
          label="Comments/Notes"
          value={formData.data.miscellaneous.comments}
          onChange={(e) => handleChange('data.miscellaneous.comments', e.target.value)}
          inputProps={{}}
        />
      </div>
      {!update && <Button variant="contained" onClick={handleSubmit}>
        Submit
      </Button>}
      {update && <Button variant="contained" onClick={handleUpdate}>
        Update
      </Button>}
      <h1 className="text-white mb-0">{text}</h1>
      {showQRCode && (
        <>
          <div style={{ display: 'flex', marginTop: '0px', justifyContent: 'center', alignItems: 'center' }}>
            {/* Display the QR code only when showQRCode is true */}
            <BrowserView>
              <QRCode size={400} value={JSON.stringify(formData)} logoImage={serverPath + "/PolarbearHead.png"} logoHeight={"81"} logoWidth={"138"} fgColor='#1a174d' bgColor='#90caf9' />
            </BrowserView>
            <MobileView>me":
              <QRCode size={300} value={JSON.stringify(formData)} logoImage={serverPath + "/PolarbearHead.png"} logoHeight={"54"} logoWidth={"92"} fgColor='#1a174d' bgColor='#90caf9' />
            </MobileView>
          </div>
        </>
      )}
      {showReset &&
        <Button variant="contained" onClick={handleReset}>
          Reset
        </Button>
      }
    </form>
  );
};

export default MatchScouting;