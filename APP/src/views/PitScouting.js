import React, { useState, useEffect } from 'react';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import { Autocomplete, MenuItem, Select, Switch, ThemeProvider, createTheme, typographyClasses } from '@mui/material';
import Header from 'components/Headers/Header';
import { Card, CardHeader, Container, Row } from 'reactstrap';
import { postPitScouting } from 'api';
import { getPitScoutingData } from 'api';
import { useHistory } from 'react-router-dom/cjs/react-router-dom.min';

const PitScouting = () => {
    const history = useHistory()
    const url = new URL(window.location.href);
    const eventName = url.pathname.split("/")[3] + url.pathname.split("/")[4];
    const year = url.pathname.split("/")[3]
    const eventCode = url.pathname.split("/")[4]
    const team = url.pathname.split("/")[5]
    const [text, setText] = useState("Submission Failed")
    const [formData, setFormData] = useState({
        event_code: eventName,
        team_number: parseInt(team),
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
    const [containerHeight, setContainerHeight] = useState(`calc(100vh - 200px)`);
    const [showForm, setShowForm] = useState(true)
    const handleChange = async (field, value) => {
        if (typeof(value) === undefined){
            value = ""
        }
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

    useEffect(() => {
        // Fetch data only when the component mounts
        if (formData.time === 0) {
            getPitScoutingData(year, eventCode, `frc${team}`, pitScoutingDataCallback);
        }
    }, [formData.time]);
    const handleSubmit = () => {
        // Set the "Time" field to the current UTC timestamp when submitting the form
        setFormData((prevData) => ({
            ...prevData,
            time: Math.floor(new Date().getTime() / 1000), // Current UTC timestamp in seconds
        }));
        postPitScouting(formData, pitScoutingStatusCallback);
        // Handle form submission logic here
    };

    const pitScoutingStatusCallback = (status)=>{
        if (status === 200){
          setShowForm(false)
          setText("Submission Successfull")
        } else {
          setShowForm(false)
          setText("Submission Failed")
        }
    }

    const pitScoutingDataCallback = (value) => {
        if (!typeof(value) == null)
        setFormData(value)
    }

    const darkTheme = createTheme({
        palette: {
          mode: "dark",
        },
    });

    const changeData = () => {
        setShowForm(true)
    }

    const backToScouting = () => {
        history.push(`../../../event/${year}/${eventCode}#pit-scouting`);
    }

    return (
        <>
            <Header />
            <div style={{ height: containerHeight, width: "100%" }}>
                <ThemeProvider theme={darkTheme}>
                <Container>
                    <Row>
                    <div style={{ height: containerHeight, width: "100%" }}>
                        <Card className="polar-box">
                        <CardHeader className="bg-transparent">
                            <h3 className="text-white mb-0">PitScouting</h3>
                        </CardHeader>
                        {showForm && <form style={{ display: 'flex', flexDirection: 'column', gap: '16px', padding: '16px' }}>
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
                                    onChange={(e) => handleChange('team_number', Math.max(0, parseInt(e.target.value, 10)))}
                                    inputProps={{ min: 0 }}
                                    disabled // Disable the Team Number field
                                />
                            </div>
                            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                                <h4 className="text-white mb-0">Drive Train</h4>
                                <Autocomplete
                                    disablePortal
                                    id="Drive Train"
                                    options={[{ label: 'Mecanum' }, { label: 'Swerve' }, { label: 'Tank' }]}
                                    renderInput={(params) => <TextField {...params} label="Drive Train"/>}
                                    freeSolo
                                    value={formData.data.drive_train}
                                    onChange={(e, value) => {handleChange('data.drive_train', value?.label)}}
                                />
                                <h4 className="text-white mb-0">Scores in Amp?</h4>
                                <Switch
                                    label="Scores in Amp?"
                                    checked={formData.data.amp_scoring}
                                    onChange={(e) => handleChange('data.amp_scoring', e.target.checked)}
                                />
                                <h4 className="text-white mb-0">Scores in Speaker?</h4>
                                <Switch
                                    label="Scores in Speaker?"
                                    checked={formData.data.speaker_scoring}
                                    onChange={(e) => handleChange('data.speaker_scoring', e.target.checked)}
                                />
                                <h4 className="text-white mb-0">Scores in Trap?</h4>
                                <Switch
                                    label="Scores in Trap?"
                                    checked={formData.data.trap_scoring}
                                    onChange={(e) => handleChange('data.trap_scoring', e.target.checked)}
                                />
                                <h4 className="text-white mb-0">Can Climb?</h4>
                                <Switch
                                    label="Can Climb?"
                                    checked={formData.data.climbing}
                                    onChange={(e) => handleChange('data.climbing', e.target.checked)}
                                />
                                <h4 className="text-white mb-0">Can Fit Under Stage?</h4>
                                <Switch
                                    label="Can Fit Under Stage?"
                                    checked={formData.data.go_under_stage}
                                    onChange={(e) => handleChange('data.go_under_stage', e.target.checked)}
                                />
                                <h4 className="text-white mb-0">Has Ground Pickup?</h4>
                                <Switch
                                    label="Ground Pickup?"
                                    checked={formData.data.ground_pick_up}
                                    onChange={(e) => handleChange('data.ground_pick_up', e.target.checked)}
                                />
                                <h4 className="text-white mb-0">Has Feeder Station Pickup?</h4>
                                <Switch
                                    label="Feeder Station Pickup?"
                                    checked={formData.data.feeder_pick_up}
                                    onChange={(e) => handleChange('data.feeder_pick_up', e.target.checked)}
                                />
                                <Autocomplete
                                    disablePortal
                                    id="Favorite Color"
                                    options={[{ label: 'Red' }, { label: 'Blue' }, { label: 'Green' }, { label: 'Yellow' }, { label: 'Orange' }, { label: 'Pink' }, { label: 'Purple' }]}
                                    renderInput={(params) => <TextField {...params} label="Favorite Color"/>}
                                    freeSolo
                                    value={formData.data.favorite_color}
                                    onChange={(e, value) => handleChange('data.favorite_color', value?.label)}
                                />
                            </div>
                            <Button variant="contained" onClick={handleSubmit}>
                                Submit
                            </Button>
                        </form>}
                        { (!showForm) &&
                            <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', padding: '16px' }}>
                                <h1 className="text-white mb-0">{text}</h1>
                                <Button variant="contained" color="primary" onClick={backToScouting}>
                                    Back To Scouting
                                </Button>
                                <Button variant="contained" color="primary" onClick={changeData}>
                                    Change Data
                                </Button>
                            </div>
                        }
                    </Card>
                </div>
                </Row>
            </Container>
            </ThemeProvider>
        </div>
        </>
    );
};

export default PitScouting;