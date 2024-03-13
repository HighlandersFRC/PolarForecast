import React, { useEffect, useState } from 'react';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import Header from 'components/Headers/Header';
import { Card, CardHeader, Container, Row } from 'reactstrap';
import { Select, MenuItem, ThemeProvider, createTheme, InputLabel, FormControl } from '@mui/material';
import { useHistory } from 'react-router-dom/cjs/react-router-dom.min';
import { getFollowUp } from 'api';
import { postFollowUp } from 'api';

const PostQualPitScoutingForm = () => {
    const history = useHistory()
    const url = new URL(window.location.href);
    const eventName = url.pathname.split("/")[3] + url.pathname.split("/")[4];
    const year = url.pathname.split("/")[3]
    const eventCode = url.pathname.split("/")[4]
    const team = url.pathname.split("/")[5].replace("team-", "")
    const defaultDeathData = {
        match_number: 0,
        death_reason: "",
        severity: '',
    };
    const [deaths, setDeaths] = useState([]);
    const [containerHeight, setContainerHeight] = useState(`calc(100vh - 200px)`);
    const [formSubmitted, setFormSubmitted] = useState(false);

    const followUpCallback = (data) => {
        setDeaths(data?.deaths)
    }

    const followUpPostCallback = ([status, detail]) => {
        if (status == 200) {
            setFormSubmitted(true);
        } else {
            alert(detail.detail)
        }
    }

    useEffect(() => {
        getFollowUp(year, eventCode, `frc${team}`, followUpCallback);
    }, []);

    const darkTheme = createTheme({
        palette: {
            mode: "dark",
        },
    });

    const handleAddDeath = () => {
        setDeaths([...deaths, defaultDeathData]);
    };

    const handleChange = (event, index) => {
        const { name, value } = event.target;
        const updatedDeaths = [...deaths];
        updatedDeaths[index][name] = value;
        setDeaths(updatedDeaths);
    };

    const handleSeverityChange = (event, index) => {
        const { value } = event.target;
        const updatedDeaths = [...deaths];
        updatedDeaths[index].severity = value;
        setDeaths(updatedDeaths);
    };

    const handleSubmit = () => {
        postFollowUp(deaths, year, eventCode, `frc${team}`, followUpPostCallback);
    };

    const handleEditForm = () => {
        setFormSubmitted(false);
    };

    const handleGoBack = () => {
        history.push(`/data/event/${year}/${eventCode}#pit-scouting`);
    };

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
                                        <h1 className="text-white mb-0">Post-Qualification Pit Scouting Form <br /> Team: #{team} </h1>
                                    </CardHeader>
                                    {formSubmitted ? (
                                        <div style={{ textAlign: 'center' }}>
                                            <h2 className="text-white mb-0">Submission Successful</h2>
                                            <Button variant="contained" color="primary" onClick={handleEditForm}>
                                                Edit Form
                                            </Button>
                                            <Button variant="contained" color="primary" onClick={handleGoBack} style={{ marginLeft: '20px' }}>
                                                Go Back
                                            </Button>
                                        </div>
                                    ) : (
                                        <div>
                                            {deaths.map((death, idx) => (
                                                <div key={idx}>
                                                    <br />
                                                    <h2 className="text-white mb-0">Death #{idx + 1}</h2>
                                                    <br />
                                                    <TextField
                                                        label="Match Number"
                                                        variant="outlined"
                                                        type="number"
                                                        fullWidth
                                                        name="match_number"
                                                        value={death.match_number}
                                                        onChange={(event) => handleChange(event, idx)}
                                                    />
                                                    <br />
                                                    <br />
                                                    <TextField
                                                        label="Reason for Team Death"
                                                        variant="outlined"
                                                        fullWidth
                                                        name="death_reason"
                                                        value={death.death_reason}
                                                        onChange={(event) => handleChange(event, idx)}
                                                    />
                                                    <br />
                                                    <br />
                                                    <FormControl variant="outlined" fullWidth>
                                                        <InputLabel id="severity">Severity</InputLabel>
                                                        <Select
                                                            labelId="severity"
                                                            label="Severity"
                                                            fullWidth
                                                            name="severity"
                                                            value={death.severity}
                                                            onChange={(event) => handleSeverityChange(event, idx)}
                                                        >
                                                            <MenuItem value={1}>1 (One time error)</MenuItem>
                                                            <MenuItem value={2}>2 (Can Be Fixed Before Elims)</MenuItem>
                                                            <MenuItem value={3}>3 (Permanently Broken)</MenuItem>
                                                        </Select>
                                                    </FormControl>
                                                    <br />
                                                    <br />
                                                </div>
                                            ))}
                                            <div>
                                                <Button variant="contained" color="primary" onClick={handleAddDeath}>
                                                    Add Death
                                                </Button>
                                            </div>
                                            <div style={{ marginTop: '20px', textAlign: 'center' }}>
                                                <Button variant="contained" color="primary" onClick={handleSubmit}>
                                                    Submit
                                                </Button>
                                            </div>
                                        </div>
                                    )}
                                </Card>
                            </div>
                        </Row>
                    </Container>
                </ThemeProvider>
            </div>
        </>
    );
};

export default PostQualPitScoutingForm;
