import React, { useState, useEffect, createRef } from 'react';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import { getMatchDetails } from 'api';
import { Switch, typographyClasses } from '@mui/material';
import { postMatchScouting } from 'api';
import { QRCode } from 'react-qrcode-logo';

const MatchScouting = ({ eventCode = '' , year, event}) => {
  const url = new URL(window.location.href);
  const serverPath = url.pathname.split("/")[0];
  const myRef = createRef()
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
        trap: 0,
      },
      miscellaneous: {
        died: 0
      }
    },
    time: 0, // Initial value set to 0
  }
  const [formData, setFormData] = useState(defaultData);  
  const [showQRCode, setShowQRCode] = useState(false);
  const [showReset, setShowReset] = useState(false)
  const [matchTeamsData, setMatchTeams] = useState([]);
  const [text, setText] = useState("")

  const matchDataCallback = (data) => {
    setMatchTeams(data)
    const updatedData = { ...formData };
    let random = Math.floor(Math.random()*6)
    try {
      updatedData.team_number = matchTeams(data)[random].substr(3)
      updatedData.match_number = data.match_number
      setFormData(updatedData)
    } catch {}
  }

  const handleScroll = () => {
      setTimeout(() => {
        myRef.current?.scrollIntoView({behavior: 'smooth'});
      }, 500)
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
    if (field === "match_number"){
      getMatchDetails(year, event, eventCode+"_qm"+value, matchDataCallback);
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
    postMatchScouting(formData, MatchScoutingStatusCallback);
  };

  const MatchScoutingStatusCallback = (status)=>{
    if (status === 200){
      setShowQRCode(false)
      setText("Submission Successful")
    } else {
      setShowQRCode(true)
      setText("Submission Failed. Use QR Code")
    }
  }

  const matchTeams = (data) => {
    try {
    let teams = []
    let allianceStr = ""
    for (let i=0; i<2;i++){
      if (i === 0){
        allianceStr = "blue"
      } else if (i === 1){
        allianceStr = "red"
      }
      teams = teams.concat(data.alliances[allianceStr].team_keys)
    }
    return teams
    } catch {
      return ["","","","","",""]
    }
  }

  const handleReset = () => {
    setShowQRCode(false)
    setShowReset(false)
    setText('')
    setFormData((prevData) => {
      prevData.match_number += 1
      getMatchDetails(year, event, eventCode+"_qm"+prevData.match_number, matchDataCallback);
      prevData.data.auto.amp = 0
      prevData.data.auto.speaker = 0
      prevData.data.teleop.amp = 0
      prevData.data.teleop.trap = 0
      prevData.data.teleop.speaker = 0
      prevData.data.miscellaneous.died = 0
      return prevData
    })
    handleScroll()
  }

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
        />
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
        <h3 className="text-white mb-0">Auto Fields</h3>
        <TextField
          label="Auto Amp"
          type="number"
          value={formData.data.auto.amp}
          onChange={(e) => handleChange('data.auto.amp', Math.min(Math.max(0, parseInt(e.target.value, 10)), 17))}
          inputProps={{ min: 0 }}
        />
        <TextField
          label="Auto Speaker"
          type="number"
          value={formData.data.auto.speaker}
          onChange={(e) => handleChange('data.auto.speaker', Math.min(Math.max(0, parseInt(e.target.value, 10)), 17))}
          inputProps={{ min: 0 }}
        />
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
        <h3 className="text-white mb-0">Teleop Fields</h3>
        <TextField
          label="Teleop Amp"
          type="number"
          value={formData.data.teleop.amp}
          onChange={(e) => handleChange('data.teleop.amp', Math.max(0, parseInt(e.target.value, 10)))}
          inputProps={{ min: 0 }}
        />
        <TextField
          label="Teleop Speaker"
          type="number"
          value={formData.data.teleop.speaker}
          onChange={(e) => handleChange('data.teleop.speaker', Math.max(0, parseInt(e.target.value, 10)))}
          inputProps={{ min: 0 }}
        />
        <TextField
          label="Teleop Trap"
          type="number"
          value={formData.data.teleop.trap}
          onChange={(e) => handleChange('data.teleop.trap', Math.max(0, parseInt(e.target.value, 10)))}
          inputProps={{ min: 0 }}
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
      <Button variant="contained" onClick={handleSubmit}>
        Submit
      </Button>
      <h1 className="text-white mb-0">{text}</h1>
      {showQRCode && (
        <>
        <div style={{ display: 'flex', marginTop: '0px', justifyContent:'center', alignItems:'center'}}>
          {/* Display the QR code only when showQRCode is true */}
          <QRCode size={400} value={JSON.stringify(formData)} logoImage={serverPath+"/PolarbearHead.png"} logoHeight={"108"} logoWidth={"184"} bgColor='#1a174d' fgColor='#90caf9'/>
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