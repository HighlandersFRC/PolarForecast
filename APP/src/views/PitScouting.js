import React, { useState, useEffect } from 'react';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import { getMatchDetails } from 'api';
import QRCode from 'react-qr-code';
import { Autocomplete, MenuItem, Select, Switch, typographyClasses } from '@mui/material';
import { postMatchScouting } from 'api';
import Header from 'components/Headers/Header';

const PitScouting = ({ defaultEventCode: eventCode = '', year, event }) => {
    const [formData, setFormData] = useState({
        event_code: "",
        team_number: 0,
        time: 0,
        data: {
            amp_scoring: false,
            speaker_scoring: false,
            trap_scoring: false,
            climbing: false,
            go_under_stage: false,
            drive_train: "",
            ground_pick_up: false,
            feeder_pick_up: false,
            favorite_color: ""
        }
    });
    const [showQRCode, setShowQRCode] = useState(false); // State to control when to show the QR code
    const [matchTeamsData, setMatchTeams] = useState([])

    const handleChange = async (field, value) => {
        setFormData((prevData) => {
            const updatedData = { ...prevData };
            const fieldPath = field.split('.');
            let currentField = updatedData;
            for (let i = 0; i < fieldPath.length - 1; i++) {
                currentField = currentField[fieldPath[i]];
            }
            currentField[fieldPath[fieldPath.length - 1]] = value;
            return updatedData
        });
    };

    const handleSubmit = () => {
        // Set the "Time" field to the current UTC timestamp when submitting the form
        setFormData((prevData) => ({
            ...prevData,
            time: Math.floor(new Date().getTime() / 1000), // Current UTC timestamp in seconds
        }));
        console.log(formData);
        // postMatchScouting(formData, MatchScoutingStatusCallback);
        // Handle form submission logic here
    };

    return (
        <>
            <Header />
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
                        disabled // Disable the Team Number field
                    />
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                    <h4 className="text-white mb-0">Scores in Amp?</h4>
                    <Switch
                        label="Scores in Amp?"
                        value={formData.data.amp_scoring}
                        onChange={(e) => handleChange('data.amp_scoring', e.target.checked)}
                    />
                    <h4 className="text-white mb-0">Scores in Speaker?</h4>
                    <Switch
                        label="Scores in Speaker?"
                        value={formData.data.speaker_scoring}
                        onChange={(e) => handleChange('data.speaker_scoring', e.target.checked)}
                    />
                    <h4 className="text-white mb-0">Scores in Trap?</h4>
                    <Switch
                        label="Scores in Trap?"
                        value={formData.data.trap_scoring}
                        onChange={(e) => handleChange('data.trap_scoring', e.target.checked)}
                    />
                    <h4 className="text-white mb-0">Can Climb?</h4>
                    <Switch
                        label="Can Climb?"
                        value={formData.data.climbing}
                        onChange={(e) => handleChange('data.climbing', e.target.checked)}
                    />
                    <h4 className="text-white mb-0">Can Fit Under Stage?</h4>
                    <Switch
                        label="Can Fit Under Stage?"
                        value={formData.data.go_under_stage}
                        onChange={(e) => handleChange('data.go_under_stage', e.target.checked)}
                    />
                    <h4 className="text-white mb-0">Drive Train</h4>
                    <Autocomplete
                        disablePortal
                        id="Drive Train"
                        options={[{ label: 'Mecanum' }, { label: 'Swerve' }, { label: 'Tank' }]}
                        renderInput={(params) => <TextField {...params} label="Drive Train" value={formData.data.drive_train} onChange={(e) => handleChange('data.drive_train', e.target.value)} />}
                        freeSolo
                    />
                    <h4 className="text-white mb-0">Has Ground Pickup?</h4>
                    <Switch
                        label="Ground Pickup?"
                        value={formData.data.ground_pick_up}
                        onChange={(e) => handleChange('data.ground_pick_up', e.target.checked)}
                    />
                    <h4 className="text-white mb-0">Has Feeder Station Pickup?</h4>
                    <Switch
                        label="Feeder Station Pickup?"
                        value={formData.data.feeder_pick_up}
                        onChange={(e) => handleChange('data.feeder_pick_up', e.target.checked)}
                    />
                    <Autocomplete
                        disablePortal
                        id="Favorite Color"
                        options={[{ label: 'Red' }, { label: 'Blue' }, { label: 'Green' }, { label: 'Yellow' }, { label: 'Orange' }, { label: 'Pink' }, { label: 'Purple' }]}
                        renderInput={(params) => <TextField {...params} label="Favorite Color" value={formData.data.favorite_color} onChange={(e) => handleChange('data.favorite_color', e.target.value)} />}
                        freeSolo
                    />
                </div>
                <Button variant="contained" onClick={handleSubmit}>
                    Submit
                </Button>
            </form>
        </>
    );
};

export default PitScouting;