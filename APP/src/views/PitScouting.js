import React, { useState, useEffect } from 'react';
import { ThemeProvider, createTheme } from '@mui/material';
import Header from 'components/Headers/Header';
import { Container, Row } from 'reactstrap';
import { postPitScouting } from 'api';
import { getPitScoutingData } from 'api';
import { useHistory } from 'react-router-dom/cjs/react-router-dom.min';
import Snowfall from 'react-snowfall';
import PitScoutingForm from 'components/Scouting/PitScoutingForm';

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
            can_climb: false,
            can_harmonize: false,
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
        if (typeof (value) === undefined) {
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

    const pitScoutingStatusCallback = (status) => {
        if (status === 200) {
            setShowForm(false)
            setText("Submission Successfull")
        } else {
            setShowForm(false)
            setText("Submission Failed")
        }
    }

    const pitScoutingDataCallback = (value) => {
        if (value !== null && value !== undefined) {
            setFormData(value);
        }
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
                                <PitScoutingForm teamPage={false}/>
                            </div>
                        </Row>
                    </Container>
                </ThemeProvider>
                <Snowfall
                    snowflakeCount={50}
                    style={{
                        position: "fixed",
                        width: "100vw",
                        height: "100vh",
                    }}
                ></Snowfall>
            </div>
        </>
    );
};

export default PitScouting;