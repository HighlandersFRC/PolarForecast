import React, { useState, useEffect } from 'react';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import { getMatchDetails } from 'api';
import QRCode from 'react-qr-code';
import { Switch, typographyClasses } from '@mui/material';
import { postMatchScouting } from 'api';

const MatchScouting = ({ defaultEventCode: eventCode = '' , year, event}) => {
  const [formData, setFormData] = useState({
    eventCode: eventCode,
    teamNumber: 0,
    matchNumber: 0,
    scoutInfo: {
      name: '',
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
  });  
  const [showQRCode, setShowQRCode] = useState(false); // State to control when to show the QR code
  const [matchTeamsData, setMatchTeams] = useState([])

  const matchDataCallback = (data) => {
    setMatchTeams(data)
    const updatedData = { ...formData };
    let random = Math.floor(Math.random()*6)
    try {
      updatedData.teamNumber = matchTeams(data)[random].substr(3)
      updatedData.matchNumber = data.match_number
      setFormData(updatedData)
    } catch {}
  }

  const handleChange = async (field, value) => {
    setFormData((prevData) => {
      const updatedData = { ...prevData };
      const fieldPath = field.split('.');
      let currentField = updatedData;
      for (let i = 0; i < fieldPath.length - 1; i++) {
        currentField = currentField[fieldPath[i]];
      }
      if (field === "scoutInfo.name") {
        currentField[fieldPath[fieldPath.length - 1]] = value; // Set minimum value of 0
      } else {
        currentField[fieldPath[fieldPath.length - 1]] = Math.max(0, value); // Set minimum value of 0
      }
      return updatedData
    });
    if (field === "matchNumber"){
      getMatchDetails(year, event, eventCode+"_qm"+value, matchDataCallback);
    }
  };

  const handleSubmit = () => {
    // Set the "Time" field to the current UTC timestamp when submitting the form
    setFormData((prevData) => ({
      ...prevData,
      time: Math.floor(new Date().getTime() / 1000), // Current UTC timestamp in seconds
    }));
    console.log(formData);
    postMatchScouting(formData, MatchScoutingStatusCallback);
    // Handle form submission logic here
  };

  const MatchScoutingStatusCallback = (status)=>{
    console.log(status)
    if (status === 200){
      setShowQRCode(false)
    } else {
      setShowQRCode(true)
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

  return (
    <form style={{ display: 'flex', flexDirection: 'column', gap: '16px', padding: '16px' }}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
        <TextField
          label="Event Code"
          value={formData.eventCode}
          onChange={(e) => handleChange('eventCode', e.target.value)}
          disabled // Disable the Event Code field
        />
        <TextField
          label="Team Number"
          type="number"
          value={formData.teamNumber}
          onChange={(e) => handleChange('teamNumber', Math.max(0, parseInt(e.target.value, 10)))}
          inputProps={{ min: 0 }}
          // disabled // Disable the Team Number field
        />
        <TextField
          label="Match Number"
          type="number"
          value={formData.matchNumber}
          onChange={(e) => handleChange('matchNumber', Math.max(0, parseInt(e.target.value, 10)))}
          inputProps={{ min: 0 }}
        />
        <TextField
          label="Scout Name"
          value={formData.scoutInfo.name}
          onChange={(e) => handleChange('scoutInfo.name', e.target.value)}
        />
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
        <h3 className="text-white mb-0">Auto Fields</h3>
        <TextField
          label="Auto Amp"
          type="number"
          value={formData.data.auto.amp}
          onChange={(e) => handleChange('data.auto.amp', Math.max(0, parseInt(e.target.value, 10)))}
          inputProps={{ min: 0 }}
        />
        <TextField
          label="Auto Speaker"
          type="number"
          value={formData.data.auto.speaker}
          onChange={(e) => handleChange('data.auto.speaker', Math.max(0, parseInt(e.target.value, 10)))}
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
      {showQRCode && (
        <div style={{ display: 'flex', marginTop: '0px', justifyContent:'center', alignItems:'center'}}>
          {/* Display the QR code only when showQRCode is true */}
          <QRCode value={JSON.stringify(formData)} />
        </div>
      )}
    </form>
  );
};

export default MatchScouting;