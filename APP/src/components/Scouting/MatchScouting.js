import React, { useState, useEffect, createRef, useRef } from 'react';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import { getMatchDetails } from 'api';
import { Switch } from '@mui/material';
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
        died: false // Changed to boolean
      },
      selectedPieces: [], // Added to store selected pieces
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

  useEffect(()=>{
    getMatchDetails(year, event, eventCode + "_qm" + String(matchNumber), (data) => matchDataCallback(data.match));
  }, [matchNumber])

  useEffect(() => {
    // console.log(formData.data.selectedPieces)
    setMatchNumber(formData.match_number)
  },[formData])

  const calculatePosition = (x, y) => {
    const scaledX = x * imageScaleFactor;
    const scaledY = y * imageScaleFactor;
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

  // Function to generate JSX for selectable pieces
  const renderSelectablePieces = (formData) => {
    return (
      <>
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
              width: `${60 * imageScaleFactor}px`,
              height: `${60 * imageScaleFactor}px`,
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
              width: `${60 * imageScaleFactor}px`,
              height: `${60 * imageScaleFactor}px`,
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
              width: `${60 * imageScaleFactor}px`,
              height: `${60 * imageScaleFactor}px`,
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
              width: `${60 * imageScaleFactor}px`,
              height: `${60 * imageScaleFactor}px`,
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
              width: `${60 * imageScaleFactor}px`,
              height: `${60 * imageScaleFactor}px`,
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
              width: `${60 * imageScaleFactor}px`,
              height: `${60 * imageScaleFactor}px`,
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
              width: `${60 * imageScaleFactor}px`,
              height: `${60 * imageScaleFactor}px`,
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
              width: `${60 * imageScaleFactor}px`,
              height: `${60 * imageScaleFactor}px`,
              cursor: 'pointer',
              filter: formData.data.selectedPieces.includes('halfway_far_right') ? 'none' : 'grayscale(100%)'
            }}
            onClick={() => handlePieceClick('halfway_far_right')}
          />
        </div>
      </>
    );
  };

  const matchDataCallback = (data) => {
    // setMatchTeams(data)
    const updatedData = { ...formData };
    let random = Math.floor(Math.random() * 6)
    try {
      updatedData.team_number = matchTeams(data)[random].substr(3)
      updatedData.match_number = data.match_number
      setFormData(updatedData)
    } catch { }
  }

  const handleChange = async (field, value) => {
    setFormData((prevData) => {
      const updatedData = { ...prevData };
      const fieldPath = field.split('.');
      let currentField = updatedData;
      for (let i = 0; i < fieldPath.length - 1; i++) {
        currentField = currentField[fieldPath[i]];
      }
      if (field === "scout_info.name") {
        currentField[fieldPath[fieldPath.length - 1]] = value;
      } else {
        currentField[fieldPath[fieldPath.length - 1]] = Math.max(0, value); // Set minimum value of 0
      }
      return updatedData
    });
    if (field === "match_number") {
        setMatchNumber(value)
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
          allianceStr = "blue"
        } else if (i === 1) {
          allianceStr = "red"
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
    setText('')
    setFormData((prevData) => {
      prevData.match_number += 1;
      prevData.team_number = 0
      getMatchDetails(year, event, eventCode + "_qm" + prevData.match_number, matchDataCallback);
      prevData.data.auto.amp = 0;
      prevData.data.auto.speaker = 0;
      prevData.data.teleop.amp = 0;
      prevData.data.teleop.trap = 0;
      prevData.data.teleop.speaker = 0;
      prevData.data.teleop.amped_speaker = 0;
      prevData.data.miscellaneous.died = 0;
      prevData.data.selectedPieces = [];
      return prevData;
    })
    setMatchNumber(matchNumber + 1)
  }

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
        />
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
              <QRCode size={400} value={JSON.stringify(formData)} logoImage={serverPath + "/PolarbearHead.png"} logoHeight={"81"} logoWidth={"138"} bgColor='#1a174d' fgColor='#90caf9' />
            </BrowserView>
            <MobileView>
              <QRCode size={300} value={JSON.stringify(formData)} logoImage={serverPath + "/PolarbearHead.png"} logoHeight={"54"} logoWidth={"92"} bgColor='#1a174d' fgColor='#90caf9' />
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